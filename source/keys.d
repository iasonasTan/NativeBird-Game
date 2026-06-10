module keys;

import raylib;
import model;
import game;

void playerKeys(Context context) {
    if(IsKeyDown(KeyboardKey.KEY_SPACE)) {
        context.getPlayer().flap(context);
    }
}