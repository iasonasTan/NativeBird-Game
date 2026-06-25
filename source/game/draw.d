module game.draw;

import std.conv;
import raylib : DrawTexture, Colors, DrawTextEx, Color, Font, Vector2;
import game.model : Model;
import game.game;
import assets;
import draw;

immutable float MODEL_SIZE        = (SCREEN_WIDTH+SCREEN_HEIGHT)/2 /12;
immutable float PIPE_WIDTH        = MODEL_SIZE*3;
immutable float PIPE_HEIGHT       = MODEL_SIZE*8;
immutable float BACKGROUND_WIDTH  = SCREEN_WIDTH*3;
immutable float BACKGROUND_HEIGHT = SCREEN_HEIGHT;

void drawTexture(Model model, Context context) {
    DrawTexture(*model.getTextureRef(context.getGameTime()), model.x.to!int, model.y.to!int, Colors.WHITE);
}

const Vector2 gameOverTextPos = Vector2(SCREEN_WIDTH/2-120, SCREEN_HEIGHT/2);
const Color gameOverTextColor = Color(222, 41, 16, 255);
Font font;

void initializeDraw() {
    font = loadMainFont();
}

void drawGameOver(Context context) {
    DrawTextEx(font, "Игра закончена!", gameOverTextPos, 50, 1, gameOverTextColor);
}