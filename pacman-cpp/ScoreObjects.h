#ifndef SCOREOBJECTS_H
#define SCOREOBJECTS_H

#include "BoolEngine\BoolEngine.h"

#include <string>
#include <vector>

//PLAYER INFORMATION
//	Player Score
class Score {
public:
	Score();

	void SetScore(const long long int & value);
	void IncreaseScore(const long long int & value);

	int ReturnScore() const;

	~Score();
private:
	long long int score;
};
//	Player Data
struct playerData
{
	std::string name;
	Score score;
};
// Vector of Players Data
typedef std::vector<playerData> playerArray;

//OBJECTS
class ScoreObject
{
public:
	ScoreObject();

	~ScoreObject();

protected:
	int value;
	ALLEGRO_BITMAP *sprite;
};
//	Pellet
class Pellet : ScoreObject
{
public:
	Pellet();

	void Caught(Score s);
};
//	Cherry
class Cherry : ScoreObject
{
public:
	Cherry();

	void Caught(Score s);
};
//	Watermelon
class Watermelon : ScoreObject
{
public:
	Watermelon();

	void Caught(Score s);
};
//	Pineapple
class Pineapple : ScoreObject
{
public:
	Pineapple();

	void Caught(Score s);
};
//	PowerUp
class PowerUp : ScoreObject
{
public:
	PowerUp();

	void Caught(Score s);
};

bool operator> (const playerData & p1, const playerData & p2);
void AddData(playerArray & a, const playerData & p);

#endif
