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
        play.action = delegate() {
            screens.getGame.setVisible(true);
            this.setVisible(false);
        };

        auto settingsButton = new Button("Настройки.", 32.0f);
        settingsButton.below(play);
        settingsButton.action = delegate() {
            this.setVisible(false);
            screens.getSettingsMenu.setVisible(true);
        };

        auto exitButton = new Button("Выход", 32.0f);
        exitButton.below(settingsButton);
        exitButton.action = delegate() {
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
    this(bool visible) {
        import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
        import raylib : Rectangle;
        super(Rectangle(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT), visible);
    }

    protected override View[] uiBuild() {
        import main : screens;

        Label title = new Label("Настройки.", 40.0f);
        title.setPos(0.0f, 100.0f);
        title.centerHorizontally();

        Button menuButton = new Button("Показать главное меню.", 32.0f);
        menuButton.below(title);
        menuButton.action = delegate() {
            setVisible(false);
            screens.getMainMenu.setVisible(true);
        };

        return [title, menuButton];
    }

    public override void safeDraw() {
        DrawTexture(menuBackground, 0, 0, Colors.WHITE);
    }

    public override void safeUpdate() {

    }
}
