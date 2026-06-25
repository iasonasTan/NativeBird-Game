module game.keys;

import raylib;
import game.model;
import game.game;

void playerKeys(Context context) {
    if(IsKeyDown(KeyboardKey.KEY_SPACE)) {
        context.getPlayer().flap(context);
    }
}