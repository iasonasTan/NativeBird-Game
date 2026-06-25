module main;

import raylib;
import game.game;
import menu.menu;
import screen;
import draw;

void main() {
    InitWindow(cast(int)SCREEN_WIDTH, cast(int)SCREEN_HEIGHT, "Местная птица");
    SetTargetFPS(60);
	initGame();

	Screen menu = new Menu(new Game());
    while (!WindowShouldClose()) {
        // Update
        menu.update();

        // Draw
        BeginDrawing();
		menu.draw();
        EndDrawing();
    }
    CloseWindow();
}
