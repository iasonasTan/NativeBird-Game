module menu.menu;

import core.stdc.stdlib : exit;
import raylib;
import screen;
import menu.view;
import menu.assets;

void initMenu() {
    loadBackground();
}

final class Menu : Screen {
    private Screen game;
    private View[] views;
    private bool handleThis = true;
    private Texture2D* backgroundRef;

    this(Screen game) {
        this.game = game;
        initializeViews();
        backgroundRef = &menuBackground;
    }

    private void startGame() {
        handleThis = false;
    }

    private void initializeViews() {
        View title = new Label("Местная птица", 40.0f);
        title.setPos(100.0f, 100.0f);
        title.centerHorizontally();
        
        auto play = new Button("Играть", 32.0f);
        play.below(title);
        play.action = delegate() {
            startGame();
        };

        auto exit = new Button("Выход", 32.0f);
        exit.below(play);
        exit.action = delegate() {
            CloseWindow();
            .exit(0);
        };
        
        views ~= [title, play, exit];
    }

    public override void draw() {
        if(handleThis) {
            DrawTexture(*backgroundRef, 0, 0, Colors.WHITE);
            foreach(v; views) {
                v.draw();
            }
        } else {
            game.draw();
        }
    }

    public override void update() {
        if(handleThis) {
            foreach(v; views) {
                v.update();
            }
        } else {
            game.update();
        }
    }
}