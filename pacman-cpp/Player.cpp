#include "Player.h"

Player::Player(const short int & l, std::string sprite_name, ALLEGRO_EVENT_QUEUE * &event_queue)
{
	lives = l;
	counter = 0;
	animationState = 1;
	dir = LEFT;
	next_dir = LEFT;
	last_dir = NON;

	PACMAN_POSX_INI = 14;
	PACMAN_POSY_INI = 23;

	SetPosition(PACMAN_POSX_INI, PACMAN_POSY_INI);
	createTimer(refresh_timer, PACMAN_REFRESH_FPS);
	RegisterTiming(event_queue);
	loadSprite(sprite, sprite_name, PACMAN_ANIMATION_STAGES, 1);
}

void Player::RegisterTiming(ALLEGRO_EVENT_QUEUE * &event_queue) {
	registerTimer(event_queue, refresh_timer);
}

void Player::StartTiming() {
	startTimer(refresh_timer);
}

void Player::SetCounter(int i) {
	counter = i;
}

void Player::SetDirection(tDirection direction) {
	dir = direction;
}

void Player::SetNextDirection(tDirection next_direction) {
	next_dir = next_direction;
}


void Player::SetLastDirection(tDirection last_direction) {
	last_dir = last_direction;
}

void Player::SetPosition(const int & x, const int & y)
{
	position.x = x;
	position.y = y;
}

void Player::SetPixelPosition(int pixel_x, int pixel_y) {
	position.pixel_x = pixel_x;
	position.pixel_y = pixel_y;
}

void Player::SetLives(const short int & l)
{
	lives = l;
}

void Player::MovePlayer(std::vector<std::vector<tGame>> &map)
{
	bool move = true;
	int disp[2] = { 0,0 };

	switch (next_dir) {
		case RIGHT: {
			disp[0] = 1;
		} break;
		case LEFT: {
			disp[0] = -1;
		} break;
		case UP: {
			disp[1] = -1;
		} break;
		case DOWN: {
			disp[1] = 1;
		} break;
		case NON: {
			move = false;
		}
	}

	if (movementPossible(GetPositionX(), GetPositionY(), map, disp[0], disp[1]) && move) {
		if (!(dir == GetOppositeDirection(next_dir))) {
			SetPosition(GetPositionX() + disp[0], GetPositionY() + disp[1]);
			SetPixelPosition(map[GetPositionY()][GetPositionX()].pixel_position[0], map[GetPositionY()][GetPositionX()].pixel_position[1]);
			dir = next_dir;
		}
		next_dir = NON;
	}
	else {
		disp[0] = 0;
		disp[1] = 0;
		switch (dir) {
		case RIGHT: {
			disp[0] = 1;
		} break;
		case LEFT: {
			disp[0] = -1;
		} break;
		case UP: {
			disp[1] = -1;
		} break;
		case DOWN: {
			disp[1] = 1;
		} break;
		}
		if (movementPossible(GetPositionX(), GetPositionY(), map, disp[0], disp[1])) {
			SetPosition(GetPositionX() + disp[0], GetPositionY() + disp[1]);
			SetPixelPosition(map[GetPositionY()][GetPositionX()].pixel_position[0], map[GetPositionY()][GetPositionX()].pixel_position[1]);
		}
	}
}

void Player::NextAnimationState()
{
	animationState = (animationState + 1) % (PACMAN_ANIMATION_STAGES);
	if (animationState == 0)
	{
		animationState++;
	}
}

void Player::Draw(float swidth, float sheight, int x, int y) {
	if (x != 0 && y != 0) {
		drawSprite(sprite[animationState], x, y, getSpriteWidth(sprite[animationState])/2, getSpriteHeight(sprite[animationState])/2, dir * PI/2, swidth, sheight);
	}
}

bool Player::movementPossible(int x, int y, std::vector<std::vector<tGame>> &map, int i , int j) {
	bool possible;
	if (ALLOWED_OBJECTS.count(map[y + j][x + i].elem) != 0) possible = true;
	else possible = false;
	return possible;
}

ALLEGRO_BITMAP * Player::GetBitmap() const
{
	return sprite[GetAnimationState()];
}

tDirection Player::GetDirection() const {
	return dir;
}

tDirection Player::GetNextDirection() const {
	return next_dir;
}

tDirection Player::GetLastDirection() const {
	return last_dir;
}

tDirection Player::GetOppositeDirection(tDirection direction) const{
	tDirection opposite = NON;

	switch (direction) {
	case RIGHT: {
		opposite = LEFT;
	}break;
	case LEFT: {
		opposite = RIGHT;
	}break;
	case DOWN: {
		opposite = UP;
	}break;
	case UP: {
		opposite = DOWN;
	}break;
	}
	return opposite;
}

int Player::GetLives() const
{
	return lives;
}

int Player::GetCounter() const {
	return counter;
}

int Player::GetPositionX() const
{
	return position.x;
}

int Player::GetPositionY() const
{
	return position.y;
}

float Player::GetPixelPositionX() const {
	return position.pixel_x;
}

float Player::GetPixelPositionY() const {
	return position.pixel_y;
}

int Player::GetAnimationState() const
{
	return animationState;
}

ALLEGRO_TIMER *Player::GetRefreshTimer() const {
	return refresh_timer;
}

Player::~Player() {
	destroySprite(sprite);
}
