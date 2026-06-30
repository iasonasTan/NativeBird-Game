module game.game;

import raylib;
import std.conv : to;

import game.draw;
import game.model : Model;
import game.model;
import game.assets;

import screen;
import draw;
import view;
import config : getConfFilePath;

private string SCORE_CONFIG_PATH;

void initGame() {
    loadGameTextures();
	SCORE_CONFIG_PATH = getConfFilePath("score");
}

interface Context {
	float getGameTime();
	float getDeltaTime();
	Player getPlayer();
	void increaseScore();
}

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

		Button menuButton = new Button("Показать меню.", 25.0f);
		menuButton.setPos(0.0f, 0.0f);
		menuButton.action = () => showMenu();

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

		PauseMenu pMenu = cast(PauseMenu)getChildScreen();
		if(pMenu !is null) {
			pMenu.enableResume(true);
		}
	}

	public override void safeDraw() {
		ClearBackground(Colors.RAYWHITE);
		drawModel(background, this);
		drawModel(player, this);
		if(drawDebug) {
			drawRectangle(player.gbounds, Colors.GREEN);
			drawRectangle(player.ghitbox, Colors.RED);
    	}
		foreach(p; pipes) {
			p.draw(delegate(Model model) {
				drawModel(model, this);
				if(drawDebug) {
					drawRectangle(model.gbounds, Colors.GREEN);
					drawRectangle(model.ghitbox, Colors.RED);
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
		scoreHandler.close();
		PauseMenu pMenu = cast(PauseMenu)getChildScreen();
		if(pMenu !is null) {
			pMenu.enableResume(false);
		}
		setVisible(false);
		setChildVisible(true);
	}

	private void showMenu() {
		if(player.alive()) {
			setVisible(!isVisible());
			setChildVisible(!getChildScreen().isVisible());
		}
	}

	public void increaseScore() {
		import std.format : format;

		scoreHandler.increaseScore();
		int[] scores = scoreHandler.get();
		string scoresStr = format("Счет: %d, Лучший результат: %d", scores[0], scores[1]);
		scoreView.setText(scoresStr);
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
			Game game = cast(Game)getParent();
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