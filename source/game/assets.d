module game.assets;

private immutable ubyte[] BIRD_1_BYTES = cast(immutable ubyte[]) import("bird1.png");
private immutable ubyte[] BIRD_2_BYTES = cast(immutable ubyte[]) import("bird2.png");
private immutable ubyte[] BIRD_D_BYTES = cast(immutable ubyte[]) import("bird_dead.png");
private immutable ubyte[] BACKGR_BYTES = cast(immutable ubyte[]) import("background.png");
private immutable ubyte[] PIPE_T_BYTES = cast(immutable ubyte[]) import("pipe_top.png");
private immutable ubyte[] PIPE_B_BYTES = cast(immutable ubyte[]) import("pipe_bot.png");
private immutable ubyte[] MUSIC_BYTES  = cast(immutable ubyte[]) import("music.wav");

import raylib : LoadImageFromMemory, LoadMusicStreamFromMemory, Music, Texture2D;
import assets : imageToTexture;
import game.draw;

// Textures
Texture2D BIRD_1;
Texture2D BIRD_2;
Texture2D BIRD_D;
Texture2D BACKGR;
Texture2D PIPE_T;
Texture2D PIPE_B;

// Sound
Music MUSIC;

void loadGameAssets() {
    BIRD_1 = imageToTexture(
        LoadImageFromMemory(".png", BIRD_1_BYTES.ptr, cast(int)BIRD_1_BYTES.length),
        MODEL_SIZE,MODEL_SIZE);
    
    BIRD_2 = imageToTexture(
        LoadImageFromMemory(".png", BIRD_2_BYTES.ptr, cast(int)BIRD_2_BYTES.length), 
        MODEL_SIZE, MODEL_SIZE);
    
    BIRD_D = imageToTexture(
        LoadImageFromMemory(".png", BIRD_D_BYTES.ptr, cast(int)BIRD_D_BYTES.length), 
        MODEL_SIZE, MODEL_SIZE);
    
    BACKGR = imageToTexture(
        LoadImageFromMemory(".png", BACKGR_BYTES.ptr, cast(int)BACKGR_BYTES.length), 
        BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
    
    PIPE_T = imageToTexture(
        LoadImageFromMemory(".png", PIPE_T_BYTES.ptr, cast(int)PIPE_T_BYTES.length), 
        PIPE_WIDTH, PIPE_HEIGHT);
    
    PIPE_B = imageToTexture(
        LoadImageFromMemory(".png", PIPE_B_BYTES.ptr, cast(int)PIPE_B_BYTES.length), 
        PIPE_WIDTH, PIPE_HEIGHT);

    MUSIC = LoadMusicStreamFromMemory(".wav", MUSIC_BYTES.ptr, MUSIC_BYTES.length);
}