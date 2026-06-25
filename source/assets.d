module assets;

import raylib;
import draw;
import std.conv : to;

immutable ubyte[] MAIN_FONT_BYTES = cast(immutable ubyte[]) import("jura_bold.ttf");

Font loadMainFont() {
    int[] codepoints;
    for (int i = 32; i <= 126; i++) {
        codepoints ~= i;
    }
    for (int i = 0x0400; i <= 0x04FF; i++) {
        codepoints ~= i;
    }

    const char* fileType = ".ttf"; 
    return LoadFontFromMemory(
        fileType, 
        MAIN_FONT_BYTES.ptr, 
        cast(int)MAIN_FONT_BYTES.length, 
        32, 
        codepoints.ptr, 
        cast(int)codepoints.length
    );
}

Texture2D imageToTexture(Image image, float w, float h) {
    ImageResize(&image, w.to!int, h.to!int);
    Texture2D texture = LoadTextureFromImage(image);
    UnloadImage(image);
    return texture;
}