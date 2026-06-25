module menu.assets;

immutable ubyte[] MENU_BACKGROUND_BYTES = cast(immutable ubyte[]) import("menu_background.png");

import raylib;
import assets;
import draw;

Texture2D menuBackground;

void loadBackground() {
    menuBackground = imageToTexture(
        LoadImageFromMemory(".png", MENU_BACKGROUND_BYTES.ptr, cast(int)MENU_BACKGROUND_BYTES.length),
        SCREEN_WIDTH,
        SCREEN_HEIGHT
    );
}