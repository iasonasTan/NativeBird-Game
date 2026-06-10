module game;

import raylib;
import std.stdio;
import std.conv;
import draw;
import model : Model;
import model;
import keys;

interface Context {
	float getGameTime();
	float getDeltaTime();
	Player getPlayer();
}

class Game : Context {
	float gameTime = 0.0f;
	Player player;
	Background background;
	Pipes pipes1;

	this(Image[] playerImages, Image backgroundImage, Image[] pipeImages) {
 		player = new Player(playerImages);
		background = new Background(backgroundImage);
		pipes1 = Pipes(new TopPipe(pipeImages[0]), new BotPipe(pipeImages[1]));
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

		// Player stuff
		drawTexture(background, this);
		drawTexture(player, this);
		drawTexture(pipes1.topPipe, this);
		drawTexture(pipes1.botPipe, this);

		EndDrawing();
	}

	void update() {
		player.update(this);
		background.update(this);
		pipes1.topPipe.update(this);
		pipes1.botPipe.update(this);
		gameTime += GetFrameTime();
	}
}

void main() {
    InitWindow(1000, 800, "Местная птица");
    SetTargetFPS(60);

	Image[] playerImages = [LoadImage("res/bird1.png"), LoadImage("res/bird2.png")];
	Image backgroundImage = LoadImage("res/background.png");
	Image[] pipeImages = [LoadImage("res/pipe_top.png"), LoadImage("res/pipe_bot.png")];
	Game ctx = new Game(playerImages, backgroundImage, pipeImages);
    while (!WindowShouldClose()) {
        ctx.update();
		ctx.draw();
    }
    CloseWindow();
}
