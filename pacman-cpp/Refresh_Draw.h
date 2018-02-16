#ifndef REFRESH_DRAW
#define REFRESH_DRAW

#include "Enemies.h"
#include "ScoreObjects.h"
#include <iostream>
void refreshLevel(Level &level, Player &pacman, ALLEGRO_EVENT &events, Score &score);
void pacmanRefreshPixel(Level &level, Player &pacman);
void pacmanRefreshPosition(Level &level, Player &pacman, Score &score);
void drawLevel(Level &level, Player &pacman, ALLEGRO_COLOR back_color, ALLEGRO_EVENT &events, int SCREEN_WIDTH, int SCREEN_HEIGHT);

#endif
