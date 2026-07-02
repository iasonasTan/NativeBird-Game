module main;

immutable string APPNAME = "native_bird";

import raylib : InitWindow, SetExitKey, SetTargetFPS, WindowShouldClose,
    CloseWindow, EndDrawing, BeginDrawing, KeyboardKey, SetWindowIcon, LoadImageFromMemory;

import assets : loadAssets, windowIcon;

import screen : Screen;
import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
import game.game : Game, PauseMenu, initGame;
import game.sound : MusicHandler;
import menu.menu : MainMenu, initMenu;

void main() {
    InitWindow(cast(int)SCREEN_WIDTH, cast(int)SCREEN_HEIGHT, "Местная птица");
    SetTargetFPS(60);
    SetExitKey(KeyboardKey.KEY_NULL);
    loadAssets();
    SetWindowIcon(windowIcon);

    initGame();
    initMenu();
	Screen mMenu = new MainMenu();
    Screen game  = new Game(mMenu, false);
    Screen pMenu = new PauseMenu(game, false);

    while (!WindowShouldClose()) {
        // Update
        mMenu.update();
        MusicHandler.getInstance().update();

        // Draw
        BeginDrawing();
		mMenu.draw();
        EndDrawing();
    }
    CloseWindow();
    MusicHandler.getInstance().unload();
}
