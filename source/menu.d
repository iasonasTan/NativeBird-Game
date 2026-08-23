module menu;

import raylib : Rectangle, DrawTexture, Texture2D, CloseWindow, Colors;
import screen : AbstractScreen;
import core.stdc.stdlib : exit;
import assets : menuBackground;
import view : View, Label, Button;

final class MainMenu : AbstractScreen {
    this() {
        import std.stdio : writeln;
        writeln("Initializing main menu screen...");
        import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
        super(Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT));
    }

    protected override View[] uiBuild() {
        import game.game : Game;
        import main : screens;

        View title = new Label("Местная птица", 40.0f);
        title.setPos(100.0f, 100.0f);
        title.centerHorizontally();

        auto play = new Button("Играть", 32.0f);
        play.below(title);
        play.action = delegate(Button _) {
            screens.getGame.setVisible(true);
            this.setVisible(false);
        };

        auto settingsButton = new Button("Настройки.", 32.0f);
        settingsButton.below(play);
        settingsButton.action = delegate(Button _) {
            this.setVisible(false);
            screens.getSettingsMenu.setVisible(true);
        };

        auto exitButton = new Button("Выход", 32.0f);
        exitButton.below(settingsButton);
        exitButton.action = delegate(Button _) {
            CloseWindow();
            .exit(0);
        };

        return [title, play, exitButton, settingsButton];
    }

    public override void safeDraw() {
        DrawTexture(menuBackground, 0, 0, Colors.WHITE);
    }

    public override void safeUpdate() {
    }
}

public final class SettingsMenu : AbstractScreen {
    private immutable string MUSIC_ENABLE  = "Включить музыку";
    private immutable string MUSIC_DISABLE = "Отключить музыку";

    this(bool visible) {
        import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
        import raylib : Rectangle;
        import std.stdio : writeln;
        super(Rectangle(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT), visible);
        writeln("Initializing settings menu...");
    }

    protected override View[] uiBuild() {
        import main : screens;

        Label title = new Label("Настройки.", 40.0f);
        title.centerHorizontally();
        float titleYPos = title.getX - title.getWidth/2;
        title.setPos(titleYPos, 100.0f);

        Label resolutionTitle = new Label("разрешение: ", 32.0f);
        resolutionTitle.below(title);

        auto action = delegate(Button source) {
            import std.stdio : File;
            import config : getConfFilePath;

            string originalText = source.getText;
            if(originalText == "монитор") {
                originalText = "monitor";
            }

            string filePath = getConfFilePath("resolution");
            File file = File(filePath, "w");
            file.writeln(originalText);
            file.close();

            import main : initializeEngine;
            initializeEngine();
        };

        Button resolution1 = new Button("1280x720", 30.0f);
        resolution1.below(resolutionTitle);
        resolution1.action = action;

        Button resolution2 = new Button("1366x768", 30.0f);
        resolution2.right(resolution1);
        resolution2.action = action;

        Button resolution3 = new Button("1920x1080", 30.0f);
        resolution3.right(resolution2);
        resolution3.action = action;

        Button resolution4 = new Button("монитор", 30.0f);
        resolution4.right(resolution3);
        resolution4.action = action;

        import config : getConfFilePath;
        import std.stdio : File;
        import std.file : exists;
        import std.string : strip;

        Button enableMusicCheckbutton = new Button("NULL", 32.0f);
        enableMusicCheckbutton.below(resolution1);
        enableMusicCheckbutton.action = delegate(Button source) {
            File file = File(getConfFilePath("music"), "w");

            // Swap text and store value
            if(source.getText == MUSIC_ENABLE) {
                source.setText(MUSIC_DISABLE);
                file.writeln("true");
            } else {
                source.setText(MUSIC_ENABLE);
                file.writeln("false");
            }
            file.close();

            import game.sound : MusicHandler;
            MusicHandler.getInstance.loadSettings;
        };

        // Load saved setting to GUI
        string musicFilePath = getConfFilePath("music");
        if(!exists(musicFilePath)) {
            File file = File(musicFilePath, "w");
            file.writeln("true");
            file.close();
            enableMusicCheckbutton.setText(MUSIC_DISABLE);
        } else {
            File file = File(musicFilePath, "r");
            string line = file.readln();
            file.close();
            enableMusicCheckbutton.setText(line !is null && line.strip == "true" ? MUSIC_DISABLE : MUSIC_ENABLE);
        }

        Button menuButton = new Button("Показать главное меню.", 32.0f);
        menuButton.below(enableMusicCheckbutton);
        menuButton.action = delegate(Button _) {
            setVisible(false);
            screens.getMainMenu.setVisible(true);
        };

        return [title, resolutionTitle, resolution1, resolution2, resolution3, resolution4,
            enableMusicCheckbutton, menuButton];
    }

    public override void safeDraw() {
        DrawTexture(menuBackground, 0, 0, Colors.WHITE);
    }

    public override void safeUpdate() {

    }
}
