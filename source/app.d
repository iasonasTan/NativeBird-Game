module game;

import raylib;
import std.stdio;
import std.conv;
import draw;
import model : Model;
import model;
import keys;
import textures;

interface Context {
	float getGameTime();
	float getDeltaTime();
	Player getPlayer();
}

class Game : Context {
	float gameTime = 0.0f;
	Player player;
	Background background;
	Pipes[] pipes;

	this() {
 		player = new Player();
		background = new Background();
		pipes = [new Pipes(), new Pipes(+SCREEN_WIDTH/2)];
	}

	override float getGameTime() {
		return gameTime;
	}

	override Player getPlayer() {
		return player;
	}

	override float getDeltaTime() {
		return GetFrameTime();
	}

	void draw() {
		BeginDrawing();
		ClearBackground(Colors.RAYWHITE);

		drawTexture(background, this);
		drawTexture(player, this);
		foreach(p; pipes) {
			p.draw((Model model) => drawTexture(model, this));
		}

		EndDrawing();
	}

	void update() {
		if(IsKeyDown(KeyboardKey.KEY_ENTER)) {
			return;
		}
		player.update(this);
		background.update(this);
		foreach(p; pipes) {
			p.update(this);
		}
		gameTime += GetFrameTime();
	}
}

void main() {
    InitWindow(1000, 800, "Местная птица");
    SetTargetFPS(60);
	loadGameTextures();

	Game ctx = new Game();
    while (!WindowShouldClose()) {
        ctx.update();
		ctx.draw();
    }
    CloseWindow();
}
