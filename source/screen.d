module screen;

import raylib;
import view;

interface Screen {
    void update();
    void draw();

    void setVisible(bool visible);
    bool isVisible();

    Rectangle getBounds();
}

abstract class AbstractScreen : Screen {
    private bool visible = true;
    private View[] views;
    private Rectangle bounds;

    this(Rectangle bounds) {
        this.bounds = bounds;

        // This call may produce segmentation fault but here,
        // all properties are private so subclass can't access them.
        views ~= uiBuild();
    }

    this(Rectangle bounds, bool visible) {
        this(bounds);
        this.visible = visible; // Gets hidden silently
    }

    public abstract void safeDraw();

    public abstract void safeUpdate();

    protected abstract View[] uiBuild();

    public override bool isVisible() { return visible; }

    public override Rectangle getBounds() { return bounds; }

    protected Rectangle* getBoundsRef() { return &bounds; }

    protected void revalidate() {
        foreach(view; views) {
            view.revalidate;
        }
    }

    public final override void setVisible(bool visible) {
        this.visible = visible;
        if(!visible) {
            onHide();
        } else {
            onShow();
        }
    }

    public final override void draw() {
        if(visible) {
            safeDraw();
            foreach(v; views) {
                if(v.isVisible) {
                    v.draw();
                }
            }
        }
    }

    public final override void update() {
        if(visible) {
            safeUpdate();
            foreach(v; views) {
                if(v.isVisible) {
                    v.update();
                }
            }
        }
    }

    public void onHide() {
    }

    public void onShow() {
    }
}
