/*
 * main.cpp
 *
 * Copyright 2012 Thomas Sigurdsen <thomas.sigurdsen@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 */
#include <stdio.h>
#include <random>

struct Tile {
    int chute;
};

/* Ugly global constants. Would use arguments and default-values, but that 
would take a bit more time. */
const int DEBUG = 2;
const int MAXTURNS = 1000;
const int MAXSIZE = 1000;

/* Main takes the size of the board to be played as an int in the first 
parameter. */
int main(int argc, char **argv) {
    std::random_device rnd;
    if (argc == 1) {
       printf("Error: too few arguments, I need a number of tiles\n");
       return -1;
    }

    *p++ = *q++;
    int mapsize = atoi(argv[1]);
    Tile *board[mapsize];
    if (mapsize > MAXSIZE) {
        printf("Warning: %d is a big board. I hope you remember your OS' kill"
                "command.", mapsize);
    }
    if (DEBUG > 1) {
         printf("mapsize: %d\n", mapsize);
    }
    /* Generate board */
    for (int tcnt = mapsize; tcnt > 0; --tcnt) {
        board[tcnt] = new Tile;
        /* Generate chutes 1 to 10 steps back. */
        if ((tcnt > 12)) {
            if ((rnd() % 20) == 7) {
                int rndnum = rnd() % (tcnt - 10) + 1;
                if (rndnum < 0) {
                    rndnum = 0;
                }
                board[tcnt]->chute = rndnum;
            } else {
                board[tcnt]->chute = 0;
            }
        }
    }
    if (DEBUG > 1) {
        printf("Board generated\n");
    }
    int player = 0;
    int turns = 0;
    /* Play the game */
    while (turns < MAXTURNS) {
        if (DEBUG > 2)
            printf("turn: %d, current tile: %d\r", turns, player);
        turns++;
        player += rnd() % 6 + 1;
        if ((player < mapsize) && (board[player]->chute)) {
            player = board[player]->chute;
        }
        if (DEBUG > 1)
            printf("turns: %d, player: %d\n", turns, player);
        if (player > mapsize)
            break;
    }
    printf("%d\n",turns);
    if (DEBUG > 1)
        printf("Done\n");
    return 0;
}
