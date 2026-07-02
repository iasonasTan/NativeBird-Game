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

private DefaultScreenSupplier screenSupplier;

/** 
 * This method supplies the screen supplier to every utility in the program.
 * WARNING: It is forbidden to use this method in a screen constructor.
 */
public ScreenSupplier screens() {
    return screenSupplier;
}

void main() {
    InitWindow(cast(int)SCREEN_WIDTH, cast(int)SCREEN_HEIGHT, "Местная птица");
    SetTargetFPS(60);
    SetExitKey(KeyboardKey.KEY_NULL);
    loadAssets();
    SetWindowIcon(windowIcon);
    import raylib : InitAudioDevice;
    InitAudioDevice();
    initGame();
    auto ignored = MusicHandler.getInstance();

    screenSupplier = new DefaultScreenSupplier(
        new MainMenu(),
        new SettingsMenu(false),
        new Game(false),
        new PauseMenu(false)
    );

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

public interface ScreenSupplier {
    MainMenu getMainMenu();
    SettingsMenu getSettingsMenu();
    Game getGame();
    PauseMenu getPauseMenu();
}

private final class DefaultScreenSupplier : ScreenSupplier {
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