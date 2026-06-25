module game.game;

import raylib;
import game.draw;
import game.model : Model;
import game.model;
import game.keys;
import game.textures;
import screen;
import draw;

void initGame() {
    loadGameTextures();
	initializeDraw();
}

interface Context {
	float getGameTime();
	float getDeltaTime();
	Player getPlayer();
}

class Game : Context, Screen {
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

	public override void draw() {
		ClearBackground(Colors.RAYWHITE);

		drawTexture(background, this);
		drawTexture(player, this);
		foreach(p; pipes) {
			p.draw((Model model) => drawTexture(model, this));
		}
		if(!player.alive()) {
			drawGameOver(this);
		}
	}

	public override void update() {
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