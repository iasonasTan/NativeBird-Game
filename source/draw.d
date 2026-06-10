module draw;

import std.conv;
import raylib;
import model : Model;
import game;

immutable float SCREEN_WIDTH  = 1000;
immutable float SCREEN_HEIGHT = 800;
immutable float MODEL_SIZE    = (SCREEN_WIDTH+SCREEN_HEIGHT)/2 /12;

void drawTexture(Model model, Context context) {
    DrawTexture(model.getTexture(context.getGameTime()), model.x.to!int, model.y.to!int, Colors.WHITE);
}