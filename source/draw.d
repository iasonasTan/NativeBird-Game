module draw;

import std.conv;
import raylib : DrawTexture, Colors, DrawText, Color;
import model : Model;
import game;

immutable float SCREEN_WIDTH      = 1000.0f;
immutable float SCREEN_HEIGHT     = 800.0f;
immutable float MODEL_SIZE        = (SCREEN_WIDTH+SCREEN_HEIGHT)/2 /12;
immutable float PIPE_WIDTH        = MODEL_SIZE*3;
immutable float PIPE_HEIGHT       = MODEL_SIZE*8;
immutable float BACKGROUND_WIDTH  = SCREEN_WIDTH*3;
immutable float BACKGROUND_HEIGHT = SCREEN_HEIGHT;

void drawTexture(Model model, Context context) {
    DrawTexture(*model.getTextureRef(context.getGameTime()), model.x.to!int, model.y.to!int, Colors.WHITE);
}

void drawGameOver(Context context) {
    DrawText("Ты проиграл!", SCREEN_WIDTH.to!int/2-120, SCREEN_HEIGHT.to!int/2, 50, Color(222, 41, 16, 255));
}