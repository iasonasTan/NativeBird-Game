module menu.view;

import raylib;
import std.string : toStringz;
import std.conv : to;
import draw;
import assets;

abstract class View {
    protected Rectangle bounds = Rectangle(0, 0, 0, 0);
    protected float m = 10.0f, p = 10.0f; // margin, padding

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
        bounds.x = SCREEN_WIDTH /2 - bounds.w /2;
    }

    public void draw() {   
    
    }

    public void update() {
    
    }

    public void revalidate() {

    }
}

class Label : View {
    private float fontSize;
    private string text;
    private Color foreground = Colors.BLACK;
    private Font font;

    this(string txt, float fsize) {
        fontSize = fsize;
        text = txt;
        font = loadMainFont();
        float[] size = calculateSize();
        super(size[0], size[1]);
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
        return [textSize.x, textSize.y];
    }

    public override void draw() {
        Vector2 position = Vector2(bounds.x+p, bounds.y+p);
        DrawTextEx(font, c_txt(), position, fontSize, p, foreground);
    }
}

class Button : Label {
    public void delegate() action;

    this(string txt, float fontSize) {
        super(txt, fontSize);
    }

    public override void update() {
        if(IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT) &&
                CheckCollisionPointRec(GetMousePosition(), bounds)) {
            action();
        }
    }
}