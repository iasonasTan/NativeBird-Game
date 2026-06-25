module view;

import raylib;
import std.string : toStringz;
import std.conv : to;
import draw;
import assets;

abstract class View {
    protected Rectangle bounds = Rectangle(0, 0, 0, 0);
    protected float m = 10.0f, p = 5.0f; // margin, padding
    private bool visible = true;

    this(float w, float h) {
        bounds.w = w;
        bounds.h = h;
    }

    public void setPos(float x, float y) {
        bounds.x = x;
        bounds.y = y;
    }

    public void above(View other) {
        bounds.y =  other.bounds.y;
        bounds.y -= other.bounds.h;
        bounds.y -= other.m + this.m;
        bounds.x =  other.bounds.x;
    }

    public void below(View other) {
        bounds.y = other.bounds.y + other.bounds.h;
        bounds.y += other.m + this.m;
        bounds.x = other.bounds.x;
    }

    public void centerHorizontally() {
        bounds.x = SCREEN_WIDTH /2 -bounds.w /2;
    }

    public void draw() {}
    public void update() {}
    public void revalidate() {}

    public void setVisible(bool v) { visible = v; }
    public bool isVisible() { return visible; }

    public int getX() { return cast(int)bounds.x; }
    public int getY() { return cast(int)bounds.y; }
    public int getWidth() { return cast(int)bounds.width; }
    public int getHeight() { return cast(int)bounds.height; }
    public int margin() { return cast(int)m; }
    public int padding() { return cast(int)p; }
}

class Label : View {
    private float fontSize;
    private string text;
    private Color background = Colors.BLACK;
    private Color foreground = Colors.WHITE;
    private Font font;

    this(string txt, float fsize) {
        fontSize = fsize;
        text = txt;
        font = loadMainFont();
        float[] size = calculateSize();
        super(size[0], size[1]);
    }

    public void setForeground(Color fg) {
        foreground = fg;
    }

    public void setBackground(Color bg) {
        background = bg;
    }

    public override void revalidate() {
        float[] size = calculateSize();
        bounds.w = size[0];
        bounds.h = size[1];
        super.revalidate();
    }

    private const(char*) c_txt() {
        const char* txt_chars = text.toStringz();
        return txt_chars;
    }

    private float[] calculateSize() {
        Vector2 textSize = MeasureTextEx(font, c_txt(), fontSize, p);
        return [textSize.x+p*2, textSize.y+p*2];
    }

    public override void draw() {
        const Vector2 position = Vector2(bounds.x+padding, bounds.y+padding);
        DrawRectangle(getX, getY, getWidth, getHeight, background);
        DrawTextEx(font, c_txt, position, fontSize, 0, foreground);
    }
}

class Button : Label {
    public void delegate() action;

    this(string txt, float fontSize) {
        super(txt, fontSize);
    }

    public override void draw() {
        super.draw();
        Vector2 position = Vector2(bounds.x+p, bounds.y+p);
        drawTextUnderline(font, c_txt, position, fontSize, 0, foreground, 2);
    }

    public override void update() {
        if(IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT) &&
                CheckCollisionPointRec(GetMousePosition(), bounds)) {
            action();
        }
    }
}