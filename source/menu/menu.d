module menu.menu;

import raylib;
import screen;
import menu.view;

final class Menu : Screen {
    private Screen game;
    private View[] views;
    private bool handleThis = true;

    this(Screen game) {
        this.game = game;
        initializeViews();
    }

    private void startGame() {
        handleThis = false;
    }

    private void initializeViews() {
        View title = new Label("Местная птица", 30.0f);
        title.setPos(100.0f, 100.0f);
        title.centerHorizontally();
        
        auto play = new Button("Играть", 22.0f);
        play.below(title);
        play.action = delegate() {
            startGame();
        };

        auto exit = new Button("Выход", 22.0f);
        exit.below(play);
        
        views ~= [title, play, exit];
    }

    public override void draw() {
        if(handleThis) {
            ClearBackground(Colors.RAYWHITE);
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