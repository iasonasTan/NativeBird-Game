module screen;

import raylib;
import view;

interface Screen {
    void update();
    void draw();
    
    void setVisible(bool visible);
    bool isVisible();
    
    Rectangle getBounds();

    void setChildScreen(Screen child);
    Screen getChildScreen();

    void setParent(Screen parent);
    Screen getParent();
}

abstract class AbstractScreen : Screen {
    private bool visible = true;
    private View[] views;
    private Screen parent = null;
    private Screen child = null;
    private Rectangle bounds;

    this(Rectangle bounds, Screen parent) {
        this.bounds = bounds;
        setParent(parent);
        views ~= uiBuild();
    }

    this(Rectangle bounds) {
        this(bounds, null);
    }

    public abstract void safeDraw();

    public abstract void safeUpdate();

    protected abstract View[] uiBuild();

    public void setChildVisible(bool visible) {
        child.setVisible(visible);
    }

    public override bool isVisible() { return visible; }

    public override Rectangle getBounds() { return bounds; }

    public final override Screen getParent() { return parent; }
    
    public final override Screen getChildScreen() { return child; }

    public final override void setParent(Screen parent) {
        this.parent = parent;
        if(parent !is null) {
            parent.setChildScreen(this);
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
        if(child !is null) {
            child.draw();
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
        if(child !is null) {
            child.update();
        }
    }

    public final override void setChildScreen(Screen child) {
        this.child = child;
    }

    public void onHide() {
    }

    public void onShow() {
    }
}