#ifndef ENEMIES_H
#define ENEMIES_H
#include <cmath>
#include "Level_Load.h"
#include "Player.h";

typedef enum tState { IDLE, SCATTER, CHASE, FRIGHTENED };

class Enemy
{
public:
	//Constructors
	Enemy();

	//Methods
	void SetState(tState s);
	//void SetPosition(int posX, int posY);
	//void SetTarget(int targetX, int targetY);
	//void MoveToTarget();
	void DrawCurrentAnimationState();

	tState GetState() const;

	//Destructor
	~Enemy();
private:
	tState state;
protected:
	int target[2];
	int position[2];
	bool leftOrRight; //0 = right 1 = left
	std::vector<ALLEGRO_BITMAP *> sprite; //REMEMBER TO DESTROY THE SPRITES
};

class RedGhost : public Enemy
{
public:
	RedGhost(int posX, int posY, int targetX, int targetY);
	void LoadGhostSprite();
	
	//~RedGhost();
private:
	int redScatterTarget[2];

};

class PinkGhost : public Enemy
{
public:
	PinkGhost(int posX, int posY, int targetX, int targetY);
	//void LoadGhostSprite();

	//~PinkGhost();
private:
	int pinkScatterTarget[2];
};

class OrangeGhost : public Enemy
{
public:
	OrangeGhost(int posX, int posY, int targetX, int targetY);
	//void LoadGhostSprite();

	//~OrangeGhost();
private:
	int orangeScatterTarget[2];

};

class BlueGhost : public Enemy
{
public:
	BlueGhost(int posX, int posY, int targetX, int targetY);
	//void LoadGhostSprite();

	//~BlueGhost();
private:
	int blueScatterTarget[2];
};

//Here go the external functions needed 

void movement(tGame_Element ** map, int & posX, int & posY, int targetX, int targetY, tDirection & lastDirection);
//This function make the ghost one position in the correct directon

int distance(int posX, int posY, int targetX, int targetY);
//This funcion simply returns the addition of the horizontal an vertical distance between coordinates of the ghost and its target.

#endif
