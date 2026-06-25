module menu.menu;

import core.stdc.stdlib : exit;
import raylib;
import screen;
import view;
import game.game;
import menu.assets;
import draw;

void initMenu() {
    loadBackground();
}

final class MainMenu : AbstractScreen {
    private Texture2D* backgroundRef;

    this() {
        super(Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT));
        backgroundRef = &menuBackground;
    }

    protected override View[] uiBuild() {
        View title = new Label("Местная птица", 40.0f);
        title.setPos(100.0f, 100.0f);
        title.centerHorizontally();
        
        auto play = new Button("Играть", 32.0f);
        play.below(title);
        play.action = delegate() {
            setChildVisible(true);
            setVisible(false);
        };

        auto exit = new Button("Выход", 32.0f);
        exit.below(play);
        exit.action = delegate() {
            CloseWindow();
            .exit(0);
        };
        
        return [title, play, exit];
    }

    public override void safeDraw() {
        DrawTexture(*backgroundRef, 0, 0, Colors.WHITE);
    }

    public override void safeUpdate() {
    }
}