module menu.menu;

import raylib : Rectangle, DrawTexture, Texture2D, CloseWindow, Colors;
import screen : AbstractScreen;
import core.stdc.stdlib : exit;
import menu.assets : loadBackground, menuBackground;
import view : View, Label, Button;

void initMenu() {
    loadBackground();
}

final class MainMenu : AbstractScreen {
    private Texture2D* backgroundRef;

    this() {
        import draw : SCREEN_WIDTH, SCREEN_HEIGHT;
        super(Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT));
        backgroundRef = &menuBackground;
    }

    protected override View[] uiBuild() {
        import game.game : Game;

        View title = new Label("Местная птица", 40.0f);
        title.setPos(100.0f, 100.0f);
        title.centerHorizontally();
        
        auto play = new Button("Играть", 32.0f);
        play.below(title);
        play.action = delegate() {
            Game game = cast(Game)getChildScreen();
			if(game !is null) {
				game.initializeObjects();
			}
            setChildVisible(true);
            setVisible(false);
        };

        auto exitButton = new Button("Выход", 32.0f);
        exitButton.below(play);
        exitButton.action = delegate() {
            CloseWindow();
            .exit(0);
        };
        
        return [title, play, exitButton];
    }

    public override void safeDraw() {
        DrawTexture(*backgroundRef, 0, 0, Colors.WHITE);
    }

    public override void safeUpdate() {
    }
}