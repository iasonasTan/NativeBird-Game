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
    private bool enabled = true;

    private this() {
        import game.assets : MUSIC;

        music = MUSIC;
        music.looping = true;

        loadSettings();
    }

    public void loadSettings() {
        import config : getConfFilePath;
        import std.stdio : File, writeln;
        import std.file : exists;
        import std.string : strip;
        import std.conv : to;

        writeln("Loading music settings...");

        string musicFilePath = getConfFilePath("music");
        if(!exists(musicFilePath)) {
            File file = File(musicFilePath, "w");
            file.writeln("true");
            file.close();
            enabled = true;
        } else {
            File file = File(musicFilePath, "r");
            string line = file.readln();
            file.close();
            writeln("Music enabled in configuration: " ~ line);
            enabled = line !is null && line.strip == "true" ? true : false;
            writeln("Music enabled in memory: " ~ enabled.to!string);
        }
    }

    public void play() {
        import raylib : PlayMusicStream, ResumeMusicStream;

        if(!enabled) return;

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
