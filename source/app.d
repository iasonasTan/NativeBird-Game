module main;

immutable string APPNAME = "native_bird";

import raylib : InitWindow, SetExitKey, SetTargetFPS, WindowShouldClose,
    CloseWindow, EndDrawing, BeginDrawing, KeyboardKey, SetWindowIcon, LoadImageFromMemory;
import assets : loadAssets, windowIcon;

import screen : Screen;
import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
import game.game : Game, PauseMenu, initGame;
import game.sound : MusicHandler;
import menu : MainMenu, SettingsMenu;

private ScreenHolder screenSupplier;

/**
 * This method supplies the screen supplier to every utility in the program.
 * WARNING: It is forbidden to use this method in a screen constructor.
 */
public ScreenSupplier screens() {
    return screenSupplier;
}

void main() {
    import draw : initDraw;
    import game.draw : initGameDraw;
    import raylib : InitAudioDevice;

    // Initialize Window with default dimensions
    InitWindow(cast(int)SCREEN_WIDTH, cast(int)SCREEN_HEIGHT, "Местная птица");
    SetTargetFPS(60);
    SetExitKey(KeyboardKey.KEY_NULL);

    initDraw;
    initGameDraw;
    loadAssets();
    SetWindowIcon(windowIcon);
    InitAudioDevice();
    initGame();
    auto _ = MusicHandler.getInstance();

    initScreens;

    while (!WindowShouldClose()) {
        // Update
        screenSupplier.update();
        MusicHandler.getInstance().update();

        // Draw
        BeginDrawing();
		screenSupplier.draw();
        EndDrawing();
    }
    CloseWindow();
    MusicHandler.getInstance().unload();
}

public void initializeEngine() {
    import draw : initDraw;
    import game.draw : initGameDraw;
    import main : initScreens;
    import game.game : initGame;
    import assets : loadAssets;

    initDraw;
    initGameDraw;
    initScreens;
    initGame;
    loadAssets;
    MusicHandler.getInstance.loadSettings;

    screenSupplier.getSettingsMenu.setVisible(true);
}

public void initScreens() {
    screenSupplier = new ScreenHolder(
        new MainMenu(),
        new SettingsMenu(false),
        new Game(false),
        new PauseMenu(false)
    );
}

public interface ScreenSupplier {
    MainMenu getMainMenu();
    SettingsMenu getSettingsMenu();
    Game getGame();
    PauseMenu getPauseMenu();
}

private final class ScreenHolder : ScreenSupplier {
    private MainMenu mainMenu;
    private SettingsMenu settingsMenu;
    private Game game;
    private PauseMenu pauseMenu;

    this(MainMenu mainMenu, SettingsMenu settingsMenu,
        Game game, PauseMenu pauseMenu) {
        this.mainMenu    = mainMenu;
        this.settingsMenu = settingsMenu;
        this.game        = game;
        this.pauseMenu   = pauseMenu;
    }

    public override MainMenu getMainMenu() {
        return mainMenu;
    }

    public override SettingsMenu getSettingsMenu() {
        return settingsMenu;
    }

    public override Game getGame() {
        return game;
    }

    public override PauseMenu getPauseMenu() {
        return pauseMenu;
    }

    public void update() {
        mainMenu.update();
        settingsMenu.update();
        game.update();
        pauseMenu.update();
    }

    public void draw() {
        mainMenu.draw();
        settingsMenu.draw();
        game.draw();
        pauseMenu.draw();
    }
}
