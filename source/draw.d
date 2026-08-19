module draw;

import raylib : Rectangle, Font, Vector2, Color, DrawRectangle, DrawTextEx, MeasureTextEx, DrawLineEx;
import raylib : InitWindow, SetWindowState, ConfigFlags, ToggleFullscreen, SetWindowSize, SetWindowPosition;

public float SCREEN_WIDTH = 1366, SCREEN_HEIGHT = 768;

public Vector2[string] resolutions;

public void initDraw() {
    import config : getConfFilePath;
    import std.file : exists, isFile;
    import std.stdio : File, writeln;
    import std.string : strip;

    resolutions = [
        "1280x720" : Vector2(1280, 720),
        "1366x768" : Vector2(1366, 768),
        "1920x1080": Vector2(1920, 1080),
        "monitor"  : monitorSize,
    ];

    string resFile = getConfFilePath("resolution");
    string resKey = "monitor";

    if(!exists(resFile)) {
        File file = File(resFile, "w");
        file.writeln("monitor");
        file.close();
    }

    File file = File(resFile, "r");
    string key = file.readln();
    if(key !is null) {
        resKey = key.strip();
    }

    Vector2 resolution = resolutions[resKey];
    SCREEN_WIDTH = resolution.x;
    SCREEN_HEIGHT = resolution.y;

    SetWindowSize(cast(int)SCREEN_WIDTH, cast(int)SCREEN_HEIGHT);

    if(resKey == "monitor") {
        SetWindowState(ConfigFlags.FLAG_WINDOW_UNDECORATED);
        SetWindowPosition(0, 0);
    }

    writeln("Window dimension: ", resolution);
}

private Vector2 monitorSize() {
    import raylib : GetCurrentMonitor, GetMonitorWidth, GetMonitorHeight;
    int m = GetCurrentMonitor();
    int w = GetMonitorWidth(m);
    int h = GetMonitorHeight(m);
    return Vector2(w, h);
}

void drawRectangle(Rectangle rectangle, Color color) {
    DrawRectangle(cast(int)rectangle.x, cast(int)rectangle.y,
        cast(int)rectangle.width, cast(int)rectangle.height, color);
}

void drawTextUnderlined(Font font, const char *text, Vector2 position, float fontSize,
        float spacing, Color tint, float lineThickness) {

    DrawTextEx(font, text, position, fontSize, spacing, tint);
    drawTextUnderline(font, text, position, fontSize, spacing, tint, lineThickness);
}

void drawTextUnderline(Font font, const char *text, Vector2 position, float fontSize,
        float spacing, Color tint, float lineThickness) {

    Vector2 textSize = MeasureTextEx(font, text, fontSize, spacing);
    Vector2 startLine = { position.x, position.y + textSize.y + 2.0f };
    Vector2 endLine = { position.x + textSize.x, position.y + textSize.y + 2.0f };
    DrawLineEx(startLine, endLine, lineThickness, tint);
}
