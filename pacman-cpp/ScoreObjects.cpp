#include "ScoreObjects.h"

Score::Score()
{
	SetScore(0);
}

void Score::SetScore(const long long int & value)
{
	score = value;
}

void Score::IncreaseScore(const long long int & value)
{
	score += value;
}

int Score::ReturnScore() const
{
	return score;
}

Score::~Score()
{}

ScoreObject::ScoreObject()
{}
ScoreObject::~ScoreObject()
{
	destroySprite(sprite);
	value = 0;
}

Pellet::Pellet()
{
	loadSprite(sprite, "Pellet.png");
	value = 10;
}

void Pellet::Caught(Score s)
{
	s.IncreaseScore(value);
	ScoreObject::~ScoreObject();
}

Cherry::Cherry()
{
	loadSprite(sprite, "Cereza-Extra.png");
	value = 200;
}

void Cherry::Caught(Score s)
{
	s.IncreaseScore(value);
	ScoreObject::~ScoreObject();
}

Watermelon::Watermelon()
{
	loadSprite(sprite, "Cereza-Extra.png");
	value = 500;
}

void Watermelon::Caught(Score s)
{
	s.IncreaseScore(value);
	ScoreObject::~ScoreObject();
}

Pineapple::Pineapple()
{
	loadSprite(sprite, "Cereza-Extra.png");
	value = 1000;
}

void Pineapple::Caught(Score s)
{
	s.IncreaseScore(value);
	ScoreObject::~ScoreObject();
}

PowerUp::PowerUp()
{
	loadSprite(sprite, "PowerUp.png");
	value = 50;
}

void PowerUp::Caught(Score s)
{
	s.IncreaseScore(value);
	ScoreObject::~ScoreObject();
}

bool operator> (const playerData & p1, const playerData & p2)
{
	return (p1.score.ReturnScore() > p2.score.ReturnScore() || (p1.score.ReturnScore() == p2.score.ReturnScore() && p1.name > p2.name));
}

void AddData(playerArray & a, const playerData & p)
{
	int i = a.size() - 1;
	std::vector<playerData>::iterator it = a.begin();
	bool stop = false;

	//Ordered insertion
	if (i == -1)
	{
		a.push_back(p);
	}
	else
	{
		while (!stop)
		{
			if (i == -1)
			{
				stop = true;
			}
			else if (a[i] > p)
			{
				stop = true;
			}
			else
			{
				i--;
			}
		}
		if (i == -1)
		{
			//Inserts on the top position
			a.insert(it, p);
		}
		else
		{
			//Inserts on i+1
			if (i + 1 != a.size())
			{
				a.insert(it + i + 1, p);
			}
			else
			{
				a.push_back(p);
			}
		}
	}
}
