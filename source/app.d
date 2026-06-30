module main;

immutable string APPNAME = "native_bird";

import raylib;
import std.stdio : writeln;

import screen : Screen;
import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
import game.game : Game, PauseMenu, initGame;
import menu.menu : MainMenu, initMenu;

void main() {
    InitWindow(cast(int)SCREEN_WIDTH, cast(int)SCREEN_HEIGHT, "Местная птица");
    SetTargetFPS(60);
    SetExitKey(KeyboardKey.KEY_NULL);
	
    writeln("Initializing game...");
    initGame();
    
    writeln("Initializing menu...");
    initMenu();

    writeln("Initializing main menu screen...");
	Screen mMenu = new MainMenu();

    writeln("Initializing game screen...");
    Screen game  = new Game(mMenu);
    game.setVisible(false);
    
    writeln("Initializing pause menu screen...");
    Screen pMenu = new PauseMenu(game);
    pMenu.setVisible(false);

    while (!WindowShouldClose()) {
        // Update
        mMenu.update();

        // Draw
        BeginDrawing();
		mMenu.draw();
        EndDrawing();
    }
    CloseWindow();
}
