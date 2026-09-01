module assets;

import raylib : LoadImageFromMemory, LoadFontFromMemory, Texture2D, Image, Font, ImageResize,
    UnloadImage, LoadTextureFromImage;
import std.conv : to;
import draw : SCREEN_WIDTH, SCREEN_HEIGHT;

private immutable ubyte[] MAIN_FONT_BYTES   = cast(immutable ubyte[]) import("jura_bold.ttf");
private immutable ubyte[] WINDOW_ICON       = cast(immutable ubyte[]) import("icon.png");
private immutable ubyte[] BACKGROUND_BYTES  = cast(immutable ubyte[]) import("menu_background.png");
private immutable string UISTRINGS_ENGLISH = cast(immutable string) import("uistrings-English.xml");
private immutable string UISTRINGS_RUSSIAN = cast(immutable string) import("uistrings-Russian.xml");
private immutable string UISTRINGS_GREEK   = cast(immutable string) import("uistrings-Greek.xml");

Texture2D menuBackground;
Font mainFont;
Image windowIcon;

void loadAssets() {
    loadMainFont();
    windowIcon = LoadImageFromMemory(".png", WINDOW_ICON.ptr, WINDOW_ICON.length);
    menuBackground = imageToTexture(
        LoadImageFromMemory(".png", BACKGROUND_BYTES.ptr, cast(int)BACKGROUND_BYTES.length),
        SCREEN_WIDTH,SCREEN_HEIGHT);
}

private void loadMainFont() {
    int[] codepoints;

    // Basic ASCII
    for (int i = 32; i <= 126; i++) { codepoints ~= i; }
    // Copyright symbol
    codepoints ~= 0x00A9;
    // Cyrillic characters
    for (int i = 0x0400; i <= 0x04FF; i++) { codepoints ~= i; }
    // Greek characters
    for (int i = 0x0370; i <= 0x0400; i++) { codepoints ~= i; }

    mainFont = LoadFontFromMemory(".ttf", MAIN_FONT_BYTES.ptr, cast(int)MAIN_FONT_BYTES.length,
        32, codepoints.ptr, cast(int)codepoints.length);
}

Texture2D imageToTexture(Image image, float w, float h) {
    ImageResize(&image, w.to!int, h.to!int);
    Texture2D texture = LoadTextureFromImage(image);
    UnloadImage(image);
    return texture;
}

import std.typecons : Nullable;
import arsd.dom : Document, XmlDocument, Element;

private string[string] uiStrings;

public void loadUiStrings() {
    import std.file : readText, exists;
    import std.stdio : File, writeln;
    import std.string : strip;
    import config : getConfFilePath;

    string languageFilePath = getConfFilePath("language");
    if(!exists(languageFilePath)) {
        File languageFileToWrite = File(languageFilePath, "w");
        languageFileToWrite.writeln("English");
        languageFileToWrite.close();
    }

    string language = readText(languageFilePath).strip;
    writeln("Loading UI strings with language = " ~ language);
    auto stringsDocument = new XmlDocument(xmlFromLanguage(language).strip);
    writeln("Loaded UI strings. StringsDocument = " ~ stringsDocument.to!string);
    Element[] stringElements = stringsDocument.getElementsByTagName("string");

    uiStrings.clear;
    foreach(element; stringElements) {
        string id = element.getAttribute("id");
        string value = element.innerText;
        if (id !is null && id != "") {
            writeln("Adding string " ~ value ~ " with id " ~ id);
            uiStrings[id] = value;
        }
    }
}

private string xmlFromLanguage(string language) {
    if(language == "Русский") {
        return UISTRINGS_RUSSIAN;
    }
    if(language == "Ελληνικά") {
        return UISTRINGS_GREEK;
    }
    return UISTRINGS_ENGLISH;
}

public string uistring(string id) {
    import core.exception : RangeError;
    try {
        return uiStrings[id];
    } catch (RangeError _) {
        return "UNTRANSLATED";
    }
}
