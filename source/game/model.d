module game.model;

import raylib : Texture2D, Rectangle;
import game.draw;
import game.game;
import game.assets;
import draw;

private immutable float GRAVITY = 150.0f;
private immutable float FLAP_STRENGTH = 150.0f;

abstract class Model {
    private Rectangle bounds;
    private Rectangle hitbox;
    private Texture2D* texture_ptr;

    this(Rectangle bounds, Rectangle hitbox, Texture2D* texture_ptr) {
        this.bounds = bounds;
        this.hitbox = hitbox;
        this.texture_ptr = texture_ptr;
    }

    this(Rectangle bounds, Rectangle hitbox, Texture2D*[] texture_ptr_array) {
        import std.exception : enforce;
        enforce(
            texture_ptr_array.length == 1,
            "Model.this(Rectangle bounds, Rectangle hitbox, Texture2D*[] texture_ptr_array) "~
            "accepts only one member in texture_ptr_array"
        );
        this(bounds, hitbox, texture_ptr_array[0]);
    }

    public bool collidesWith(Model other) {
        return
            this.hitbox.x + this.hitbox.w  > other.hitbox.x &&
            this.hitbox.x < other.hitbox.x + other.hitbox.w &&
            this.hitbox.y + this.hitbox.h  > other.hitbox.y &&
            this.hitbox.y < other.hitbox.y + other.hitbox.h;
    }

    public void update(Context context) {
        // blank
    }

    public Texture2D* getTextureRef() {
        import std.conv : to;
        if(texture_ptr is null) {
            throw new NoTexturePresentException("Attempted to get not existing texture of " ~ this.to!string);
        }
        return texture_ptr;
    }

    public final float x() { return bounds.x; }
    public final float y() { return bounds.y; }
    public final float w() { return bounds.width; }
    public final float h() { return bounds.height; }

    public final void dx(float d) {
        bounds.x += d;
        hitbox.x += d;
    }

    public final void dy(float d) {
        bounds.y += d;
        hitbox.y += d;
    }

    public final void w(float v) { this.bounds.width = v; }
    public final void h(float v) { this.bounds.height = v; }

    public final Rectangle gbounds() { return bounds; }
    public final Rectangle ghitbox() { return hitbox; }
}

final class Player : Model {
    private Texture2D* textureDead, textureOnFlap;
    private bool dead = false;
    private float velocityY = 0.2f;

    private int flappingFrames = 0;
    private const int FLAPPING_FRAMES_MAX = 15;

    this() {
        Rectangle bounds = Rectangle(SCREEN_WIDTH/2-MODEL_SIZE/2, SCREEN_HEIGHT/2-MODEL_SIZE/2, MODEL_SIZE, MODEL_SIZE);
        Rectangle hitbox = Rectangle(
            bounds.x,
            bounds.y +bounds.height/7.0f,
            bounds.width -bounds.width/10.0f,
            bounds.height -bounds.height/2.2f
        );
        super(bounds, hitbox, &BIRD_1);
        textureDead = &BIRD_D;
        textureOnFlap = &BIRD_2;
    }

    public override void update(Context context) {
        import raylib : IsMouseButtonDown, IsKeyDown, MouseButton, KeyboardKey;
        float dt = context.getDeltaTime();
        velocityY += GRAVITY * dt;
        dy(velocityY * dt);
        const bool mouseButtonPressed = IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT) ||
            IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT);
        const bool keyPressed = IsKeyDown(KeyboardKey.KEY_SPACE);
        if(!dead && (keyPressed || mouseButtonPressed)) {
            flap();
        }
        if(y > SCREEN_HEIGHT) {
            dead = true;
        }
    }

    public void kill() {
        dead = true;
    }

    public bool alive() {
        return !dead;
    }

    public void flap() {
        velocityY = -FLAP_STRENGTH;
        flappingFrames = 0;
    }

    public override Texture2D* getTextureRef() {
        if(dead) {
            return textureDead;
        } else if (flappingFrames < FLAPPING_FRAMES_MAX) {
            // Bird has flapped, returning flap texture this time.
            flappingFrames++;
            return textureOnFlap;
        }
        return super.getTextureRef();
    }
}

final class Background : Model {
    private immutable float SPEED = -95.0f;

    this() {
        Rectangle bounds = Rectangle(0.0f, 0.0f, SCREEN_WIDTH*3, SCREEN_HEIGHT*1);
        Rectangle hitbox = Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
        super(bounds, hitbox, [&BACKGR]);
    }

    public override void update(Context context) {
        if(context.getPlayer().alive()) {
            dx(SPEED * context.getDeltaTime());
            if(x+w < SCREEN_WIDTH) {
                dx(-x);
            }
        }
    }
}

final class Pipe : Model {
    public static Pipe createTopPipe(float y, float offx) {
        return new Pipe(y, offx, &PIPE_T);
    }

    public static Pipe createBotPipe(float y, float offx) {
        return new Pipe(y, offx, &PIPE_B);
    }

    private immutable float SPEED = -120.0f;

    private this(float y, float offsetX, Texture2D* texture_ptr) {
        Rectangle bounds = Rectangle(SCREEN_WIDTH, y, PIPE_WIDTH, PIPE_HEIGHT);
        Rectangle hitbox = Rectangle(
            bounds.x+bounds.width/5.0f,bounds.y+bounds.height/10f,
            bounds.width-bounds.width /5.0f*2, bounds.height-bounds.height/10f*2
        );
        super(bounds, hitbox, texture_ptr);
        dx(offsetX);
    }

    public override void update(Context context) {
        dx(SPEED * context.getDeltaTime());
        if(context.getPlayer().collidesWith(this)) {
            context.getPlayer().kill();
        }
    }
}

final class Pipes {
    private bool crossed = false;
    public Pipe topPipe;
    public Pipe botPipe;

    this() {
        this(0.0f);
    }

    this(float offsetX) {
        float[] newY = getPipesY();
        topPipe = Pipe.createTopPipe(newY[0], offsetX);
        botPipe = Pipe.createBotPipe(newY[1], offsetX);
    }

    public void update(Context context) {
        if(context.getPlayer().alive()) {
            topPipe.update(context);
            botPipe.update(context);
            updatePosition();
            updateScore(context);
        }
    }

    private void updateScore(Context context) {
        if(!crossed && topPipe.x+topPipe.w < context.getPlayer().gbounds.x) {
            context.increaseScore();
            crossed = true;
        }
    }

    private void updatePosition() {
        if(topPipe.x+topPipe.w < 0) {
            topPipe.dx(SCREEN_WIDTH+topPipe.w);
            botPipe.dx(SCREEN_WIDTH+botPipe.w);
            float[] newY = getPipesY();
            topPipe.dy(newY[0]-topPipe.y);
            botPipe.dy(newY[1]-botPipe.y);
            crossed = false;
        }
    }

    public void draw(void delegate(Model model) drawer) {
        drawer(topPipe);
        drawer(botPipe);
    }

    public float[] getPipesY() {
        import std.random : uniform;
        float topY = 0;

        float min = -PIPE_HEIGHT/2.0f;
        float max = 0.0f;
        if(min < max) {
            topY = uniform(-PIPE_HEIGHT/2, 0.0f);
        }

        float botY = topY+PIPE_HEIGHT +MODEL_SIZE;
        return [topY, botY];
    }
}

public final class NoTexturePresentException : Exception {
    /**
    * Creates a new instance of Exception. The nextInChain parameter is used
    * internally and should always be $(D null) when passed by user code.
    * This constructor does not automatically throw the newly-created
    * Exception; the $(D throw) expression should be used for that purpose.
    */
    @nogc @safe pure nothrow this(string msg)
    {
        super(msg);
    }
}
