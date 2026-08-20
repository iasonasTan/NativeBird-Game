module assets;

import raylib : LoadImageFromMemory, LoadFontFromMemory, Texture2D, Image, Font, ImageResize,
    UnloadImage, LoadTextureFromImage;
import std.conv : to;
import draw : SCREEN_WIDTH, SCREEN_HEIGHT;

private immutable ubyte[] MAIN_FONT_BYTES  = cast(immutable ubyte[]) import("jura_bold.ttf");
private immutable ubyte[] WINDOW_ICON      = cast(immutable ubyte[]) import("icon.png");
private immutable ubyte[] BACKGROUND_BYTES = cast(immutable ubyte[]) import("menu_background.png");

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
    for (int i = 32; i <= 126; i++)        { codepoints ~= i; }
    for (int i = 0x0400; i <= 0x04FF; i++) { codepoints ~= i; }

    mainFont = LoadFontFromMemory(".ttf", MAIN_FONT_BYTES.ptr, cast(int)MAIN_FONT_BYTES.length,
        32, codepoints.ptr, cast(int)codepoints.length);
}

Texture2D imageToTexture(Image image, float w, float h) {
    ImageResize(&image, w.to!int, h.to!int);
    Texture2D texture = LoadTextureFromImage(image);
    UnloadImage(image);
    return texture;
}
