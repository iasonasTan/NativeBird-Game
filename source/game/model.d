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
    public float x, y;
    public float w, h;

    Texture2D*[] texturePtrs;
    int textureIdx = 0;
    const float textureDelta = 0.5f;
    float lastTextureSwitch  = 0.0f;

    this(float x, float y, float w, float h, Texture2D*[] texturePtrs) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.texturePtrs = texturePtrs;
    }

    bool collidesWith(Model other) {
        return
            this.x + this.w > other.x && this.x < other.x + other.w &&
            this.y + this.h > other.y && this.y < other.y + other.h;
    }

    void update(Context context) {
        // blank
    }

    Texture2D* getTextureRef(float gameTime) {
        if(texturePtrs.length != 1 && lastTextureSwitch+textureDelta < gameTime) {
            textureIdx++;
            if(textureIdx >= texturePtrs.length) {
                textureIdx = 0;
            }
            lastTextureSwitch = gameTime;
        }
        return texturePtrs[textureIdx];
    }
}

final class Player : Model {
    Texture2D* textureDead;
    bool dead = false;
    float velocityY = 0.1f;

    this() {
        super(SCREEN_WIDTH/2-MODEL_SIZE/2, SCREEN_HEIGHT/2-MODEL_SIZE/2, MODEL_SIZE, MODEL_SIZE, [&BIRD_1, &BIRD_2]);
        textureDead = &BIRD_D;
    }

    override void update(Context context) {
        float dt = context.getDeltaTime();
        velocityY += GRAVITY * dt;
        y += velocityY * dt;
        if(!dead && IsKeyDown(KeyboardKey.KEY_SPACE)) {
            context.getPlayer().flap(context);
        }
        if(y > SCREEN_HEIGHT) {
            dead = true;
        }
    }

    void kill() {
        dead = true;
    }

    bool alive() {
        return !dead;
    }

    void flap(Context context) {
        velocityY = -FLAP_STRENGTH;
    }

    override Texture2D* getTextureRef(float gameTime) {
        if(dead) {
            return textureDead;
        } else {
            return super.getTextureRef(gameTime);
        }
    }
}

final class Background : Model {
    immutable float SPEED = -75.0f;

    this() {
        super(0.0f, 0.0f, SCREEN_WIDTH*3, SCREEN_HEIGHT*1, [&BACKGR]);
    }

    override void update(Context context) {
        if(context.getPlayer().alive()) {
            x += SPEED * context.getDeltaTime();
            if(x+w < SCREEN_WIDTH) {
                x = 0.0f;
            }
        }
    }
}

class Pipe : Model {
    immutable float SPEED = -100.0f;

    this(float y, Texture2D* texture) {
        super(SCREEN_WIDTH*1, y, PIPE_WIDTH, PIPE_HEIGHT, [texture]);
    }

    override void update(Context context) {
        x += SPEED * context.getDeltaTime();
        if(context.getPlayer().collidesWith(this)) {
            context.getPlayer().kill();
        }
    }
}

final class Pipes {
    Pipe topPipe;
    Pipe botPipe;

    this() {
        this(0);
    }

    this(float offsetX) {
        float[] newY = getPipesY();
        topPipe = new Pipe(newY[0], &PIPE_T);
        botPipe = new Pipe(newY[1], &PIPE_B);
        topPipe.x += offsetX;
        botPipe.x += offsetX;
    }

    void update(Context context) {
        if(context.getPlayer().alive()) {
            topPipe.update(context);
            botPipe.update(context);
            if(topPipe.x+topPipe.w < 0) {
                topPipe.x = SCREEN_WIDTH;
                botPipe.x = SCREEN_WIDTH;
                float[] newY = getPipesY();
                topPipe.y = newY[0];
                botPipe.y = newY[1];
            }
        }
    }

    void draw(void delegate(Model model) drawer) {
        drawer(topPipe);
        drawer(botPipe);
    }

    float[] getPipesY() {
        float topY = uniform(-PIPE_HEIGHT/2, 0.0f);
        float botY = topY+PIPE_HEIGHT+MODEL_SIZE*2;
        return [topY, botY];
    }
}