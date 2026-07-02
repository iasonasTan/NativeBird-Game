module game.sound;

import raylib : Music;
import game.assets : MUSIC;
import std.stdio : writeln;

final class MusicHandler {
    private static MusicHandler instance = null;

    public static MusicHandler getInstance() {
        if(instance is null)
            instance = new MusicHandler();
        return instance;
    }

    private Music music;
    private bool paused = false;

    private this() {
        import game.assets : MUSIC;
        
        music = MUSIC;
        music.looping = true;
    }

    public void play() {
        import raylib : PlayMusicStream, ResumeMusicStream;
        if(paused) {
            writeln("Resuming music...");
            paused = false;
            ResumeMusicStream(music);
        } else {
            writeln("Playing music...");
            PlayMusicStream(music);
        }
    }

    public void pause() {
        import raylib : PauseMusicStream;
        writeln("Pausing music...");
        PauseMusicStream(music);
        paused = true;
    }

    public void reset() {
        import raylib : StopMusicStream;
        writeln("Stopping music...");
        paused = false;
        StopMusicStream(music);
    }

    public void update() {
        import raylib : UpdateMusicStream;
        UpdateMusicStream(music);
    }

    public void unload() {
        import raylib : UnloadMusicStream, CloseAudioDevice;
        UnloadMusicStream(music);
        CloseAudioDevice();
    }
}