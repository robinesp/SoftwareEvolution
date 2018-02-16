#include "Refresh_Draw.h"

//REFRESHING

void refreshLevel(Level &level, Player &pacman, ALLEGRO_EVENT &events, Score &score) {
	//Refresh Pacman
	if (events.timer.source == pacman.GetRefreshTimer()) {
		if (pacman.GetCounter() >= 3) {
			pacmanRefreshPosition(level, pacman, score);
		}
		else {
			pacmanRefreshPixel(level, pacman);
		}
		pacman.NextAnimationState();
	}

	//Refresh Ghosts


	//Refresh Map


	//Refresh UI

}

void pacmanRefreshPosition(Level &level, Player &pacman, Score &score) {
	tGame_Element aux = MISTAKE;

	level.SetMapElem(pacman.GetPositionY(), pacman.GetPositionX(), EMPTY);
	pacman.MovePlayer(level.GetMap());
	aux = level.GetElement(pacman.GetPositionY(), pacman.GetPositionX());
	if (aux == PELLET)
	{
		score.IncreaseScore(1);
	}
	else if (aux == POWER_UP)
	{
		score.IncreaseScore(5);
	}
	else if (aux == PINEAPPLE || aux == CHERRY)
	{
		score.IncreaseScore(50);
	}
	level.SetMapElem(pacman.GetPositionY(), pacman.GetPositionX(), PLAYER);
	pacman.SetCounter(0);
}

void pacmanRefreshPixel(Level &level, Player &pacman) {
	bool draw_dir = false;
	int i = 0;

	switch (pacman.GetNextDirection()) {
	case RIGHT: {
		if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 1, 0) && !(pacman.GetDirection() == pacman.GetOppositeDirection(pacman.GetNextDirection()))) {
			pacman.SetPixelPosition(pacman.GetPixelPositionX() + level.GetRowPixelElem() / 4, pacman.GetPixelPositionY());
		}
		else {
			draw_dir = true;
		}
	} break;
	case LEFT: {
		if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), -1, 0) && !(pacman.GetDirection() == pacman.GetOppositeDirection(pacman.GetNextDirection()))) {
			pacman.SetPixelPosition(pacman.GetPixelPositionX() - level.GetRowPixelElem() / 4, pacman.GetPixelPositionY());
		}
		else {
			draw_dir = true;
		}
	} break;
	case UP: {
		if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 0, -1) && !(pacman.GetDirection() == pacman.GetOppositeDirection(pacman.GetNextDirection()))) {
			pacman.SetPixelPosition(pacman.GetPixelPositionX(), pacman.GetPixelPositionY() - level.GetColumnPixelElem() / 4);
		}
		else {
			draw_dir = true;
		}
	} break;
	case DOWN: {
		if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 0, 1) && !(pacman.GetDirection() == pacman.GetOppositeDirection(pacman.GetNextDirection()))) {
			pacman.SetPixelPosition(pacman.GetPixelPositionX(), pacman.GetPixelPositionY() + level.GetColumnPixelElem() / 4);
		}
		else {
			draw_dir = true;
		}
	} break;
	case NON: {
		draw_dir = true;
	}
	}

	if (draw_dir) {
		switch (pacman.GetDirection()) {
		case RIGHT: {
			if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 1, 0)) {
				pacman.SetPixelPosition(pacman.GetPixelPositionX() + level.GetRowPixelElem() / 4, pacman.GetPixelPositionY());
			}
		} break;
		case LEFT: {
			if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), -1, 0)) {
				pacman.SetPixelPosition(pacman.GetPixelPositionX() - level.GetRowPixelElem() / 4, pacman.GetPixelPositionY());
			}
		} break;
		case UP: {
			if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 0, -1)) {
				pacman.SetPixelPosition(pacman.GetPixelPositionX(), pacman.GetPixelPositionY() - level.GetColumnPixelElem() / 4);
			}
		} break;
		case DOWN: {
			if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 0, 1)) {
				pacman.SetPixelPosition(pacman.GetPixelPositionX(), pacman.GetPixelPositionY() + level.GetColumnPixelElem() / 4);
			}
		} break;
		}
	}
	pacman.SetCounter(pacman.GetCounter() + 1 + i);
}


//DRAWING


void drawLevel(Level &level, Player &pacman, ALLEGRO_COLOR back_color, ALLEGRO_EVENT &events, int SCREEN_WIDTH, int SCREEN_HEIGHT) {
	float swidth, sheight;

	for (int i = 0; i < level.GetSize(); i++)
	{
		for (int j = 0; j < level.GetSize(i); j++)
		{
			swidth = level.GetRowPixelElem() / getSpriteWidth(level.GetBitmap(i, j));
			sheight = level.GetColumnPixelElem() / getSpriteHeight(level.GetBitmap(i, j));

			if (level.GetElement(i, j) != PLAYER && level.GetElement(i, j) != RED_GHOST && level.GetElement(i, j) != BLUE_GHOST && level.GetElement(i, j) != PINK_GHOST && level.GetElement(i, j) != ORANGE_GHOST)
			{
				drawSprite(level.GetBitmap(i, j), level.GetPixelPositionX(j), level.GetPixelPositionY(i), getSpriteWidth(level.GetBitmap(i, j)) / 2, getSpriteHeight(level.GetBitmap(i, j)) / 2, level.AngleFromElement(level.GetElement(i, j)), swidth, sheight);
			}
			else if (level.GetElement(i, j) == PLAYER) {
				pacman.Draw(swidth, sheight, pacman.GetPixelPositionX(), pacman.GetPixelPositionY());
			}
		}
	}
	showScreen(back_color, INITIAL_LEVEL_POS_X, INITIAL_LEVEL_POS_Y, LEVEL_LENGTH_X, LEVEL_LENGTH_Y, SCREEN_WIDTH, SCREEN_HEIGHT);
}
