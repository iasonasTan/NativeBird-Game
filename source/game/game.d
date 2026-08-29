module game.game;

import raylib;
import std.conv : to;

import game.model;
import screen : AbstractScreen, Screen;
import draw : drawRectangle, SCREEN_WIDTH, SCREEN_HEIGHT;
import view : Label, Button, View;

private string SCORE_CONFIG_PATH;

void initGame() {
	import std.stdio : writeln;
	writeln("Initializing game...");
	import config : getConfFilePath;
	import game.assets : loadGameAssets;
    loadGameAssets();
	SCORE_CONFIG_PATH = getConfFilePath("score");
}

interface Context {
	float getGameTime();
	float getDeltaTime();
	Player getPlayer();
	void increaseScore();
}

import game.sound : MusicHandler;

final class Game : AbstractScreen, Context {
	// Logic
	private float gameTime = 0.0f;
	private bool drawDebug = false;
	private ScoreHandler scoreHandler;

	// Models
	private Player player;
	private Background background;
	private Pipes[] pipes;

	// Gui
	private Label gameOverView;
	private Label scoreView;

	this(bool visible) {
		import std.stdio : writeln;
		writeln("Initializing game screen...");
		super(Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), visible);
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

		Button menuButton = new Button("Показать меню.", 25.0f);
		menuButton.setPos(0.0f, 0.0f);
		menuButton.action = (Button _) => showMenu();

		scoreView = new Label("", 25.0f);
		scoreView.centerHorizontally();

		return [gameOverView, menuButton, scoreView];
	}

	public void initializeObjects() {
		scoreView.setText("Счет: 0");
		player = new Player();
		background = new Background();
		pipes = [new Pipes(), new Pipes(+SCREEN_WIDTH/2)];
		gameOverView.setVisible(false);
		scoreHandler = new ScoreHandler();
		int bscore = scoreHandler.get()[1];
		scoreView.setText("Счет: 0, Лучший результат: " ~ bscore.to!string);
		scoreView.right(getBounds);
	}

	public override void safeDraw() {
		import game.draw : drawModel;

		const Color DEBUG_GREEN = Color(0, 228, 48, 255/3);
		const Color DEBUG_RED   = Color(230, 41, 55, 255/3);

		ClearBackground(Colors.RAYWHITE);
		drawModel(background, this);
		drawModel(player, this);
		if(drawDebug) {
			drawRectangle(player.gbounds, DEBUG_GREEN);
			drawRectangle(player.ghitbox, DEBUG_RED);
    	}
		foreach(p; pipes) {
			import game.model : Model;
			p.draw(delegate(Model model) {
				drawModel(model, this);
				if(drawDebug) {
					drawRectangle(model.gbounds, DEBUG_GREEN);
					drawRectangle(model.ghitbox, DEBUG_RED);
				}
			});
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
			onGameOver();
		}
		if(IsKeyPressed(KeyboardKey.KEY_ESCAPE)) {
			showMenu();
		}
	}

	public void onGameOver() {
		import main : screens;
		showMenu();
		scoreHandler.close();
	}

	private void showMenu() {
		import main : screens;
		setVisible(false);
		screens.getPauseMenu.enableResume(player.alive());
		screens.getPauseMenu.setVisible(true);
	}

	public void increaseScore() {
		import std.format : format;
		scoreHandler.increaseScore();
		int[] scores = scoreHandler.get();
		string scoresStr = format("Счет: %d, Лучший результат: %d", scores[0], scores[1]);
		scoreView.setText(scoresStr);
	}

	public override void onShow() {
		super.onShow();
		MusicHandler.getInstance.play();
	}

	public override void onHide() {
		super.onHide();
		MusicHandler.getInstance.pause();
	}
}

final class PauseMenu : AbstractScreen {
	private Button resume;

	this(bool visible) {
		import std.stdio : writeln;
		writeln("Initializing pause menu screen...");
		float width = 500.0f, height = 300.0f;
		super(Rectangle(SCREEN_WIDTH/2-width/2,SCREEN_HEIGHT/2-height/2,width,height), visible);
	}

	public void enableResume(bool v) {
		resume.setVisible(v);
	}

	public override View[] uiBuild() {
		import main : screens;

		View title = new Label("Игра приостановлена.", 40.0f);
		title.setPos(0.0f, getBounds.y + title.margin);

		Rectangle fakeBounds = getBounds;
		fakeBounds.x -= 15.0f;
		title.left(fakeBounds);

		auto restart = new Button("Перезапустить игру.", 32.0f);
		restart.below(title);
		restart.action = delegate(Button _) {
			MusicHandler.getInstance.reset();
			screens.getGame.initializeObjects();
			screens.getGame.setVisible(true);
			setVisible(false);
		};

		auto menu = new Button("Показать главное меню.", 32.0f);
		menu.below(restart);
		menu.action = delegate(Button _) {
			screens.getMainMenu.setVisible(true);
			setVisible(false);
			screens.getGame.initializeObjects();
			MusicHandler.getInstance.reset();
		};

		resume = new Button("Возобновить игру.", 32.0f);
		resume.below(menu);
		resume.action = delegate(Button _) {
			screens.getGame.setVisible(true);
			setVisible(false);
		};

		getBoundsRef.width = restart.getWidth;

		return [title, restart, menu, resume];
	}

	public override void safeDraw() {
		drawRectangle(getBounds, Colors.YELLOW);
	}

	public override void safeUpdate() {
	}
}

import std.file : exists, isFile;
import std.stdio : File;

final class ScoreHandler {
	private int score, bestScore;
	private bool saveOnClose = false;

	this() {
		score = bestScore = 0;
		loadFromFile();
	}

	public void loadFromFile() {
		import std.string : chomp;

		if(!exists(SCORE_CONFIG_PATH) || !isFile(SCORE_CONFIG_PATH)) {
			return;
		}
		File file = File(SCORE_CONFIG_PATH, "r");
		string bestScoreStr = file.readln();
		if(bestScoreStr !is null) {
			bestScore = bestScoreStr.chomp().to!int;
		}
		file.close();
	}

	public void increaseScore() {
		score++;
		if(score > bestScore) {
			bestScore = score;
			saveOnClose = true;
		}
	}

	public void close() {
		if(saveOnClose) {
			File file = File(SCORE_CONFIG_PATH, "w");
			file.writeln(score.to!string);
			file.close();
		}
	}

	public int[] get() {
		return [score, bestScore];
	}
}
