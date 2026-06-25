module menu.view;

import raylib;
import std.string : toStringz;
import std.conv : to;
import draw;
import assets;

abstract class View {
    protected float x, y; // xpos, ypos
    protected float w, h; // width, height
    protected float m = 10.0f, p = 10.0f; // margin, padding

    this(float w, float h) {
        this.w = w;
        this.h = h;
    }

    public void setPos(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public void above(View other) {
        this.y =  other.y;
        this.y -= other.h;
        this.y -= other.m + this.m;
        this.x =  other.x;
    }

    public void below(View other) {
        this.y = other.y + other.h;
        this.y += other.m + this.m;
        this.x = other.x;
    }

    public void centerHorizontally() {
        this.x = SCREEN_WIDTH /2 - w /2;
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
        w = size[0];
        h = size[1];
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
        Vector2 position = Vector2(x+p, y+p);
        DrawTextEx(font, c_txt(), position, fontSize, p, foreground);
    }
}

class Button : Label {
    public void delegate() action;

    this(string txt, float fontSize) {
        super(txt, fontSize);
    }

    public override void update() {
        if(IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            Rectangle clickPos = Rectangle(GetMouseX(), GetMouseY(), 0, 0);
            Rectangle thisBody = Rectangle(x, y, w, h);
            if(CheckCollisionRecs(clickPos, thisBody)) {
                action();
            }
        }
    }
}