#ifndef PLAYER_H
#define PLAYER_H
#include "Level_Load.h"
#include <set>
#include <vector>

// Pacman Timing: Cada 0.136 segundos avanza una posicion en el mapa. Por cada posicion, se dibuja 4 veces. Luego
// Se actualiza a 7.35 FPS y se dibuja a 29.4 FPS

typedef enum tDirection { RIGHT, DOWN, LEFT, UP, NON  };
const std::set<tGame_Element> ALLOWED_OBJECTS = {EMPTY, RED_GHOST, BLUE_GHOST, PINK_GHOST, ORANGE_GHOST, PLAYER, PELLET, POWER_UP, CHERRY, PINEAPPLE};

struct pixel_position {
	int x, y;
	float pixel_x, pixel_y;
};


const int PACMAN_ANIMATION_STAGES = 10;
const float PACMAN_REFRESH_FPS = 29.4;

class Player
{
public:
	Player(const short int & l, std::string sprite_name, ALLEGRO_EVENT_QUEUE * &event_queue);

	void RegisterTiming(ALLEGRO_EVENT_QUEUE * &event_queue);
	void StartTiming();
	void SetCounter(int i);
	void SetDirection(tDirection direction);
	void SetNextDirection(tDirection next_direction);
	void SetLastDirection(tDirection last_direction);
	
	void SetPosition(const int & x, const int & y);
	void SetPixelPosition(int pixel_x, int pixel_y);
	void SetLives(const short int & l);
	void MovePlayer(std::vector<std::vector<tGame>> &map);
	void NextAnimationState();
	void Draw(float swidth, float sheight, int x, int y);
	bool movementPossible(int x, int y, std::vector<std::vector<tGame>> &map, int i, int j);

	ALLEGRO_BITMAP *GetBitmap() const;
	tDirection GetDirection() const;
	tDirection GetNextDirection() const;
	tDirection GetLastDirection() const;
	tDirection GetOppositeDirection(tDirection direction) const;
	int GetLives() const;
	int GetCounter() const;
	int GetPositionX() const;
	int GetPositionY() const;
	float GetPixelPositionX() const;
	float GetPixelPositionY() const;
	int GetAnimationState() const;
	ALLEGRO_TIMER *GetRefreshTimer() const;

	~Player();
private:
	int PACMAN_POSX_INI, PACMAN_POSY_INI;
	short int lives, animationState, counter;
	pixel_position position;
	std::vector<ALLEGRO_BITMAP *> sprite;
	tDirection dir, next_dir, last_dir;
	ALLEGRO_TIMER *refresh_timer;
};


#endif
