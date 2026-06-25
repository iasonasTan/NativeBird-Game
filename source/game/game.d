module game.game;

import raylib;
import game.draw;
import game.model : Model;
import game.model;
import game.assets;
import menu.menu;
import screen;
import draw;
import view;

void initGame() {
    loadGameTextures();
}

interface Context {
	float getGameTime();
	float getDeltaTime();
	Player getPlayer();
}

final class Game : Context, Screen {
	private float gameTime = 0.0f;
	private Player player;
	private Background background;
	private Pipes[] pipes;
	private PauseMenu pauseMenu;
	private Label gameOverView;
	private Menu mainMenu;

	this(Menu mainMenu) {
		this.mainMenu = mainMenu;
 		initializeObjects();
		gameOverView.setPos(0.0f, pauseMenu.bounds.y -gameOverView.getHeight);
		gameOverView.centerHorizontally();
		gameOverView.setForeground(Color(222, 41, 16, 255));
	}

	public override float getGameTime() { return gameTime; }
	public override Player getPlayer() { return player; }
	public override float getDeltaTime() { return GetFrameTime(); }

	public void hide() {
		mainMenu.handleThis = true;
	}

	public void initializeObjects() {
		player = new Player();
		background = new Background();
		pipes = [new Pipes(), new Pipes(+SCREEN_WIDTH/2)];
		pauseMenu = new PauseMenu(this);
		gameOverView = new Label("Игра закончена!", 33.0f);
	}

	public override void draw() {
		ClearBackground(Colors.RAYWHITE);

		drawTexture(background, this);
		drawTexture(player, this);
		foreach(p; pipes) {
			p.draw((Model model) => drawTexture(model, this));
		}
		if(!player.alive()) {
			gameOverView.draw();
		}
		pauseMenu.draw();
	}

	// TODO: Make draw boolean private and add method for showing and hiding game

	public override void update() {
		if(!pauseMenu.visible) {
			background.update(this);
			player.update(this);
			foreach(p; pipes) {
				p.update(this);
			}
			gameTime += GetFrameTime();
			if(player.y > SCREEN_HEIGHT) {
				pauseMenu.visible = true;
			}
		} else {
			pauseMenu.update();
		}
		if(IsKeyPressed(KeyboardKey.KEY_ESCAPE) && player.alive()) {
			pauseMenu.visible = !pauseMenu.visible;
		}
	}
}

final class PauseMenu : Screen {
	private Game game;
	bool visible = false;
	Rectangle bounds = Rectangle(
		SCREEN_WIDTH/3.5,SCREEN_HEIGHT/2.5,
		SCREEN_WIDTH/3,SCREEN_HEIGHT/3);
	private View[] views;

	this(Game game) {
		this.game = game;
		View title = new Label("Игра приостановлена.", 40.0f);
		title.setPos(0.0f, bounds.y + title.margin);
		title.centerHorizontally();

		auto resume = new Button("Перезапустить игру.", 32.0f);
		resume.below(title);
		resume.action = delegate() {
			game.initializeObjects();
			visible = false;
		};

		auto menu = new Button("Показать главное меню.", 32.0f);
		menu.below(resume);
		menu.action = delegate() {
			game.hide();
		};

		views ~= [title, resume, menu];
	}

	public override void draw() {
		if(visible) {
			drawRectangle(bounds, Colors.YELLOW);
			foreach(v; views) {
                v.draw();
            }
		}
	}

	public override void update() {
		if(visible) {
			foreach(v; views) {
				v.update();
			}
		}
	}
}