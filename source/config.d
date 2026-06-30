module config;

import std.path : buildPath;

/** 
 * Returns absolute path to configuration file.
 * Returns: configuration file path as string
 */
public string getConfFilePath(string fileName) @safe {
    import main : APPNAME;
    import std.stdio : File;
    import std.file : exists, mkdirRecurse;

    string homeDir = getUserHomeDirectory();
    string dir = buildPath(homeDir, ".config", APPNAME);
    if(!exists(dir)) {
        mkdirRecurse(dir);
    }

    string configFilePath = buildPath(dir, fileName);
    return configFilePath;
}

/**
 * Returns the absolute path to the current user's home directory.
 * Returns: current directory path if the directory cannot be determined.
 */
string getUserHomeDirectory() @safe {
    import std.process : environment;
    import std.file : getcwd;

    version(Windows)
    {
        string home = environment.get("USERPROFILE");
        if (home.length == 0) {
            string homeDrive = environment.get("HOMEDRIVE");
            string homePath = environment.get("HOMEPATH");
            if (homeDrive.length > 0 && homePath.length > 0) {
                home = buildPath(homeDrive, homePath);
            } else {
                return getcwd();
            }
        }
        return home;
    }
    else version(Posix)
    {
        string home = environment.get("HOME");
        if (home.length == 0) {
            return getcwd();
        }
        return home;
    }
    else
    {
        return getcwd();
    }
}