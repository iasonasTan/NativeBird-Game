module game.draw;

import std.conv : to;
import raylib : DrawTexture, Colors, DrawTextEx, Color, Font, Vector2;
import game.model : Model;
import game.game : Context;
import draw : SCREEN_WIDTH, SCREEN_HEIGHT, drawRectangle;

public float MODEL_SIZE, PIPE_WIDTH, PIPE_HEIGHT, BACKGROUND_WIDTH, BACKGROUND_HEIGHT;

public void initGameDraw() {
    MODEL_SIZE        = ((SCREEN_WIDTH + SCREEN_HEIGHT) / 2.0f) / 9.0f;
    PIPE_WIDTH        = MODEL_SIZE * 2.0f;
    PIPE_HEIGHT       = MODEL_SIZE * 4.0f;
    BACKGROUND_WIDTH  = SCREEN_WIDTH * 3.0f;
    BACKGROUND_HEIGHT = SCREEN_HEIGHT;
}

void drawModel(Model model, Context context) {
    DrawTexture(*model.getTextureRef(context.getGameTime()), model.x.to!int, model.y.to!int, Colors.WHITE);
}
