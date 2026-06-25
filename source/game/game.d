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

final class Game : AbstractScreen, Context {
	private float gameTime = 0.0f;
	private Player player;
	private Background background;
	private Pipes[] pipes;
	private Label gameOverView;

	this(Screen parent) {
		super(Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), parent);
		initializeObjects();
	}

	public override float getGameTime() { return gameTime; }
	public override Player getPlayer() { return player; }
	public override float getDeltaTime() { return GetFrameTime(); }

	public override View[] uiBuild() {
		gameOverView = new Label("Игра закончена!", 33.0f);
		gameOverView.setPos(0.0f, 100.0f);
		gameOverView.centerHorizontally();
		gameOverView.setVisible(false);
		gameOverView.setForeground(Color(222, 41, 16, 255));

		return [gameOverView];
	}

	public void initializeObjects() {
		player = new Player();
		background = new Background();
		pipes = [new Pipes(), new Pipes(+SCREEN_WIDTH/2)];
		gameOverView.setVisible(false);
		Screen child = getChildScreen();
		PauseMenu pMenu = cast(PauseMenu)child;
		if(pMenu !is null) {
			pMenu.enableResume(true);
		}
	}

	public override void safeDraw() {
		ClearBackground(Colors.RAYWHITE);
		drawTexture(background, this);
		drawTexture(player, this);
		foreach(p; pipes) {
			p.draw((Model model) => drawTexture(model, this));
		}
		if(!player.alive()) {
			gameOverView.setVisible(true);
		}
	}

	public override void safeUpdate() {
		background.update(this);
		player.update(this);
		foreach(p; pipes) {
			p.update(this);
		}
		gameTime += GetFrameTime();
		if(player.y > SCREEN_HEIGHT) {
			Screen child = getChildScreen();
			PauseMenu pMenu = cast(PauseMenu)child;
			if(pMenu !is null) {
				pMenu.enableResume(false);
			}
			setVisible(false);
			setChildVisible(true);
		}
		if(IsKeyPressed(KeyboardKey.KEY_ESCAPE) && player.alive()) {
			setVisible(!isVisible());
			setChildVisible(!getChildScreen().isVisible());
		}
	}
}

final class PauseMenu : AbstractScreen {
	private Button resume;

	this(Screen parent) {
		super(Rectangle(SCREEN_WIDTH/3.5,SCREEN_HEIGHT/2.5,SCREEN_WIDTH/3,SCREEN_HEIGHT/3), parent);
	}

	public void enableResume(bool v) {
		resume.setVisible(v);
	}

	public override View[] uiBuild() {
		View title = new Label("Игра приостановлена.", 40.0f);
		title.setPos(0.0f, getBounds.y + title.margin);
		title.centerHorizontally();

		auto restart = new Button("Перезапустить игру.", 32.0f);
		restart.below(title);
		restart.action = delegate() {
			setVisible(false);
			Screen parent = getParent();
			Game game = cast(Game)parent;
			if(game !is null) {
				game.initializeObjects();
			}
			getParent().setVisible(true);
		};

		auto menu = new Button("Показать главное меню.", 32.0f);
		menu.below(restart);
		menu.action = delegate() {
			setVisible(false);
			getParent().getParent().setVisible(true);
		};

		resume = new Button("Возобновить игру.", 32.0f);
		resume.below(menu);
		resume.action = delegate() {
			setVisible(false);
			getParent().setVisible(true);
		};

		return [title, restart, menu, resume];
	}

	public override void safeDraw() {
		drawRectangle(getBounds, Colors.YELLOW);
	}

	public override void safeUpdate() {
	}
}