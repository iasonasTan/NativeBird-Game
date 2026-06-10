module model;

import std.stdio;
import std.conv;
import draw;
import raylib;
import game;
import keys;

immutable float GRAVITY = 100.0f;
immutable float FLAP_STRENGTH = 100.0f;

abstract class Model {
    float x, y;
    float w, h;

    Texture2D[] textures;
    int textureIdx = 0;
    const float textureDelta = 0.5f;
    float lastTextureSwitch  = 0.0f;

    this(float x, float y, float w, float h, Image[] images) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        foreach(image; images) {
            textures ~= imageToTexture(image);
        }
    }

    this(float x, float y, Image[] images) {
        this(x, y, MODEL_SIZE, MODEL_SIZE, images);
    }

    void update(Context context) {
        // blank
    }

    Texture2D getTexture(float gameTime) {
        if(textures.length != 1 && lastTextureSwitch+textureDelta < gameTime) {
            textureIdx++;
            if(textureIdx >= textures.length) {
                textureIdx = 0;
            }
            lastTextureSwitch = gameTime;
        }
        
        return textures[textureIdx];
    }

    final Texture2D imageToTexture(Image image) {
        ImageResize(&image, w.to!int, h.to!int);
        Texture2D texture = LoadTextureFromImage(image);
        UnloadImage(image);
        return texture;
    }
}

final class Player : Model {
    Texture2D textureDead;
    bool dead = false;
    float velocityY = 0.1f;

    this(Image[] images) {
        super(SCREEN_WIDTH/2-MODEL_SIZE/2, SCREEN_HEIGHT/2-MODEL_SIZE/2,images);
        textureDead = imageToTexture(LoadImage("res/bird_dead.png"));
    }

    override void update(Context context) {
        float dt = context.getDeltaTime();
        velocityY += GRAVITY * dt;
        y += velocityY * dt;
        playerKeys(context);
    }

    void flap(Context context) {
        velocityY = -FLAP_STRENGTH;
    }

    override Texture2D getTexture(float gameTime) {
        if(dead) {
            return textureDead;
        } else {
            return super.getTexture(gameTime);
        }
    }
}

final class Background : Model {
    immutable float SPEED = -75.0f;

    this(Image image) {
        super(0.0f, 0.0f, SCREEN_WIDTH*3, SCREEN_HEIGHT*1, [image]);
    }

    override void update(Context context) {
        x += SPEED * context.getDeltaTime();
        if(x+w < SCREEN_WIDTH) {
            x = 0.0f;
        }
    }
}

abstract class Pipe : Model {
    immutable float SPEED = -100.0f;
    immutable float PIPE_WIDTH = MODEL_SIZE*3;
    immutable float PIPE_HEIGHT= MODEL_SIZE*8;

    this(Image image) {
        super(SCREEN_WIDTH*1, getRandomY(), PIPE_WIDTH, PIPE_HEIGHT, [image]);
    }

    override void update(Context context) {
        x += SPEED * context.getDeltaTime();
        if(x+w < 0) {
            x = SCREEN_WIDTH;
            y = getRandomY();
        }
    }

    abstract float getRandomY();
}

import std.random;

final class TopPipe : Pipe {
    this(Image image) {
        super(image);
    }

    override float getRandomY() {
        return uniform(-PIPE_HEIGHT+MODEL_SIZE, 0.0f);
    }
}

final class BotPipe : Pipe {
    this(Image image) {
        super(image);
    }

    override float getRandomY() {
        return uniform(SCREEN_HEIGHT/2+MODEL_SIZE, SCREEN_HEIGHT-MODEL_SIZE);
    }
}

struct Pipes {
    TopPipe topPipe;
    BotPipe botPipe;
}