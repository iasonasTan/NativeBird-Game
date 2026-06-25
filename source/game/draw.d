module game.draw;

import std.conv : to;
import raylib : DrawTexture, Colors, DrawTextEx, Color, Font, Vector2;
import game.model : Model;
import game.game : Context;
import draw : SCREEN_WIDTH, SCREEN_HEIGHT, drawRectangle;

immutable float MODEL_SIZE        = (SCREEN_WIDTH+SCREEN_HEIGHT)/2 /12;
immutable float PIPE_WIDTH        = MODEL_SIZE*3;
immutable float PIPE_HEIGHT       = MODEL_SIZE*8;
immutable float BACKGROUND_WIDTH  = SCREEN_WIDTH*3;
immutable float BACKGROUND_HEIGHT = SCREEN_HEIGHT;

void drawModel(Model model, Context context) {
    DrawTexture(*model.getTextureRef(context.getGameTime()), model.x.to!int, model.y.to!int, Colors.WHITE);
}