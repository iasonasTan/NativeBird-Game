module draw;

import raylib;

immutable float SCREEN_WIDTH  = 1000.0f;
immutable float SCREEN_HEIGHT = 800.0f;

void drawRectangle(Rectangle rectangle, Color color) {
    DrawRectangle(cast(int)rectangle.x, cast(int)rectangle.y, 
        cast(int)rectangle.width, cast(int)rectangle.height, color);
}

void drawTextUnderlined(Font font, const char *text, Vector2 position, float fontSize, 
        float spacing, Color tint, float lineThickness) {

    DrawTextEx(font, text, position, fontSize, spacing, tint);
    Vector2 textSize = MeasureTextEx(font, text, fontSize, spacing);
    Vector2 startLine = { position.x, position.y + textSize.y + 2.0f };
    Vector2 endLine = { position.x + textSize.x, position.y + textSize.y + 2.0f };
    DrawLineEx(startLine, endLine, lineThickness, tint);
}

void drawTextUnderline(Font font, const char *text, Vector2 position, float fontSize, 
        float spacing, Color tint, float lineThickness) {

    Vector2 textSize = MeasureTextEx(font, text, fontSize, spacing);
    Vector2 startLine = { position.x, position.y + textSize.y + 2.0f };
    Vector2 endLine = { position.x + textSize.x, position.y + textSize.y + 2.0f };
    DrawLineEx(startLine, endLine, lineThickness, tint);
}