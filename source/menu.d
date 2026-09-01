module menu;

import raylib : Rectangle, DrawTexture, Texture2D, CloseWindow, Colors;
import screen : AbstractScreen;
import core.stdc.stdlib : exit;
import assets : menuBackground;
import view : View, Label, Button;
import assets : uistring;

final class MainMenu : AbstractScreen {
    this() {
        import std.stdio : writeln;
        writeln("Initializing main menu screen...");
        import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
        super(Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), () => uiBuild);
    }

    private View[] uiBuild() {
        import game.game : Game;
        import main : screens;
        import std.datetime : Clock;
        import std.conv : to;

        View title = new Label(uistring("game_name"), 40.0f);
        title.setPos(100.0f, 100.0f);
        title.centerHorizontally();

        auto play = new Button(uistring("play"), 32.0f);
        play.below(title);
        play.action = delegate(Button _) {
            screens.getGame.setVisible(true);
            this.setVisible(false);
        };

        auto settingsButton = new Button(uistring("settings"), 32.0f);
        settingsButton.below(play);
        settingsButton.action = delegate(Button _) {
            this.setVisible(false);
            screens.getSettingsMenu.setVisible(true);
        };

        auto exitButton = new Button(uistring("exit"), 32.0f);
        exitButton.below(settingsButton);
        exitButton.action = delegate(Button _) {
            CloseWindow();
            .exit(0);
        };

        auto graphics = new Label(uistring("graphics"), 29.0f);
        graphics.bottom(getBounds.height);
        auto music = new Label(uistring("music"), 29.0f);
        music.above(graphics);
        string yearStr = Clock.currTime.year.to!string;
        auto copyright = new Label(uistring("copyright1")~yearStr~uistring("copyright2"), 29.0f);
        copyright.above(music);
        auto owner = new Label(uistring("developed"), 31.0f);
        owner.above(copyright);

        return [title, play, exitButton, settingsButton, graphics, music, copyright, owner];
    }

    public override void safeDraw() {
        DrawTexture(menuBackground, 0, 0, Colors.WHITE);
    }

    public override void safeUpdate() {
    }
}

public final class SettingsMenu : AbstractScreen {
    this(bool visible) {
        import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
        import raylib : Rectangle;
        import std.stdio : writeln;
        super(Rectangle(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT), visible, () => uiBuild);
        writeln("Initializing settings menu...");
    }

    private View[] uiBuild() {
        import main : screens;

        Label title = new Label(uistring("settings"), 40.0f);
        title.centerHorizontally();
        float titleYPos = title.getX - title.getWidth/2;
        title.setPos(titleYPos, 100.0f);

        auto resolution = resolutionViews(title);
        auto language = languageViews(resolution[1]);

        import config : getConfFilePath;
        import std.stdio : File;
        import std.file : exists;
        import std.string : strip;

        Button enableMusicCheckbutton = new Button("NULL", 32.0f);
        enableMusicCheckbutton.below(language[1]);
        enableMusicCheckbutton.action = delegate(Button source) {
            File file = File(getConfFilePath("music"), "w");

            // Swap text and store value
            if(source.getText == uistring("enable_music")) {
                source.setText(uistring("disable_music"));
                file.writeln("true");
            } else {
                source.setText(uistring("enable_music"));
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
            enableMusicCheckbutton.setText(uistring("disable_music"));
        } else {
            File file = File(musicFilePath, "r");
            string line = file.readln();
            file.close();
            enableMusicCheckbutton.setText(
                uistring(line !is null && line.strip == "true" ?
                    "disable_music" : "enable_music")
            );
        }

        Button menuButton = new Button(uistring("return_mmenu"), 32.0f);
        menuButton.below(enableMusicCheckbutton);
        menuButton.action = delegate(Button _) {
            setVisible(false);
            screens.getMainMenu.setVisible(true);
        };

        return language~resolution~[cast(View)title, cast(View)enableMusicCheckbutton, cast(View)menuButton];
    }

    private View[] resolutionViews(View top) {
        Label resolutionTitle = new Label(uistring("resolution"), 32.0f);
        resolutionTitle.below(top);

        auto resolutionAction = delegate(Button source) {
            import std.stdio : File;
            import config : getConfFilePath;

            string originalText = source.getText;
            if(originalText == uistring("monitor")) {
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
        resolution1.action = resolutionAction;

        Button resolution2 = new Button("1366x768", 30.0f);
        resolution2.right(resolution1);
        resolution2.action = resolutionAction;

        Button resolution3 = new Button("1920x1080", 30.0f);
        resolution3.right(resolution2);
        resolution3.action = resolutionAction;

        Button resolution4 = new Button(uistring("monitor"), 30.0f);
        resolution4.right(resolution3);
        resolution4.action = resolutionAction;

        return [resolutionTitle, resolution1, resolution2, resolution3, resolution4];
    }

    private View[] languageViews(View top) {
        Label languageTitle = new Label(uistring("language"), 32.0f);
        languageTitle.below(top);

        auto languageAction = delegate(Button source) {
            import std.stdio : File;
            import config : getConfFilePath;

            string filePath = getConfFilePath("language");
            File file = File(filePath, "w");
            file.writeln(source.getText);
            file.close();

            import main : initializeEngine;
            initializeEngine();
        };

        Button language1 = new Button("English", 30.0f);
        language1.below(languageTitle);
        language1.action = languageAction;

        Button language2 = new Button("Ελληνικά", 30.0f);
        language2.right(language1);
        language2.action = languageAction;

        Button language3 = new Button("Русский", 30.0f);
        language3.right(language2);
        language3.action = languageAction;

        return [languageTitle, language1, language2, language3];
    }

    public override void safeDraw() {
        DrawTexture(menuBackground, 0, 0, Colors.WHITE);
    }

    public override void safeUpdate() {

    }
}
