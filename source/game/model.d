module game.model;

import raylib;
import std.random;
import std.conv;
import game.draw;
import game.game;
import game.assets;
import draw;

immutable float GRAVITY = 100.0f;
immutable float FLAP_STRENGTH = 100.0f;

abstract class Model {
    private Rectangle bounds;
    private Rectangle hitbox;
    private Texture2D*[] texturePtrs;
    
    private int textureIdx = 0;
    private const float textureDelta = 0.5f;
    private float lastTextureSwitch  = 0.0f;

    this(Rectangle bounds, Rectangle hitbox, Texture2D*[] texturePtrs) {
        this.bounds = bounds;
        this.hitbox = hitbox;
        this.texturePtrs = texturePtrs;
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

    public Texture2D* getTextureRef(float gameTime) {
        if(texturePtrs.length != 1 && lastTextureSwitch+textureDelta < gameTime) {
            textureIdx++;
            if(textureIdx >= texturePtrs.length) {
                textureIdx = 0;
            }
            lastTextureSwitch = gameTime;
        }
        return texturePtrs[textureIdx];
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
    private Texture2D* textureDead;
    private bool dead = false;
    private float velocityY = 0.1f;

    this() {
        Rectangle bounds = Rectangle(SCREEN_WIDTH/2-MODEL_SIZE/2, SCREEN_HEIGHT/2-MODEL_SIZE/2, MODEL_SIZE, MODEL_SIZE);
        Rectangle hitbox = Rectangle(bounds.x+15, bounds.y+15, bounds.width-30, bounds.height-30);
        super(bounds, hitbox, [&BIRD_1, &BIRD_2]);
        textureDead = &BIRD_D;
    }

    public override void update(Context context) {
        float dt = context.getDeltaTime();
        velocityY += GRAVITY * dt;
        dy(velocityY * dt);
        if(!dead && IsKeyDown(KeyboardKey.KEY_SPACE)) {
            context.getPlayer().flap(context);
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

    public void flap(Context context) {
        velocityY = -FLAP_STRENGTH;
    }

    public override Texture2D* getTextureRef(float gameTime) {
        if(dead) {
            return textureDead;
        } else {
            return super.getTextureRef(gameTime);
        }
    }
}

final class Background : Model {
    private immutable float SPEED = -75.0f;

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

class Pipe : Model {
    private immutable float SPEED = -100.0f;

    this(float y, Texture2D* texture) {
        Rectangle bounds = Rectangle(SCREEN_WIDTH*1, y, PIPE_WIDTH, PIPE_HEIGHT);
        Rectangle hitbox = Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
        super(bounds, hitbox, [texture]);
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
        this(0);
    }

    this(float offsetX) {
        float[] newY = getPipesY();
        topPipe = new Pipe(newY[0], &PIPE_T);
        botPipe = new Pipe(newY[1], &PIPE_B);
        topPipe.dx(offsetX);
        botPipe.dx(offsetX);
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
            crossed = true;
        }
    }

    public void draw(void delegate(Model model) drawer) {
        drawer(topPipe);
        drawer(botPipe);
    }

    public float[] getPipesY() {
        float topY = uniform(-PIPE_HEIGHT/2, 0.0f);
        float botY = topY+PIPE_HEIGHT+MODEL_SIZE*2;
        return [topY, botY];
    }
}