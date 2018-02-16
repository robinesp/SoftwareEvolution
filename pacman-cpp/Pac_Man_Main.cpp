#include "Refresh_Draw.h"
#include "DataSave.h"

#include <iostream>
#include <cmath>

//USER INTERFACE
class UserInterface {
public:
	UserInterface();

	void refreshUI();
	void drawUI();
	void copyScore(int sc);

	~UserInterface();

private:
	ALLEGRO_BITMAP *life1, *life2, *life3, *life4, *life5, *livesUI, *scoreUI, *scoreBoardUI, *levelBannerUI, *controlsUI;
	ALLEGRO_FONT *font1, *font2, *font3;

	float UI_LIVES_POS_X, UI_LIVES_POS_Y, LIFE_X_OFFSET, swidth_UI_lives, sheight_UI_lives, swidth_inital_life, sheight_initial_life;
	float CONTROLS_POS_X, CONTROLS_POS_Y, swidth_controls, sheight_controls;

	float LEVEL_BANNER_POS_X, LEVEL_BANNER_POS_Y, swidth_level_banner, sheight_level_banner;
	float LEVEL_TEXT_POS_X, LEVEL_TEXT_POS_Y, LEVEL_TEXT_CONSTRAINT_X, LEVEL_TEXT_CONSTRAINT_Y;

	float SCORE_POS_X, SCORE_POS_Y, swidth_score, sheight_score;
	float SCORE_TEXT_POS_X, SCORE_TEXT_POS_Y, SCORE_TEXT_CONSTRAINT_X, SCORE_TEXT_CONSTRAINT_Y;
	float SCOREBOARD_POS_X, SCOREBOARD_POS_Y, swidth_scoreboard, sheight_scoreboard;
	float TOPSCORES_POS_X, TOPSCORES_POS_Y, TOPSCORES_CONSTRAINT_X, TOPSCORES_CONSTRAINT_Y, TOPSCORES_JUMP_Y;

	int scoreAux;
};

UserInterface::UserInterface() {
	loadSprite(livesUI, "UI_Lives.png");
	UI_LIVES_POS_X = SCREEN_WIDTH * 1 / 16;
	UI_LIVES_POS_Y = SCREEN_HEIGHT * 1 / 12;
	swidth_UI_lives = (SCREEN_WIDTH * 1 / 8) / getSpriteWidth(livesUI);
	sheight_UI_lives = (SCREEN_HEIGHT * 1 / 12) / getSpriteHeight(livesUI);

	loadSprite(life1, "Life_Icon.png");
	loadSprite(life2, "Life_Icon.png");
	loadSprite(life3, "Life_Icon.png");
	loadSprite(life4, "Life_Icon.png");
	loadSprite(life5, "Life_Icon.png");
	swidth_inital_life = (SCREEN_WIDTH * 1 / 32) / getSpriteWidth(life1);
	sheight_initial_life = (SCREEN_HEIGHT * 1 / 12) / getSpriteHeight(life1);

	loadSprite(controlsUI, "UI_Controls.png");
	CONTROLS_POS_X = SCREEN_WIDTH * 1 / 16;
	CONTROLS_POS_Y = SCREEN_HEIGHT * 1 / 4;
	swidth_controls = (SCREEN_WIDTH * 1 / 8) / getSpriteWidth(controlsUI);
	sheight_controls = (SCREEN_HEIGHT * 2 / 3) / getSpriteHeight(controlsUI);


	loadSprite(levelBannerUI, "UI_Level_Banner.png");
	loadFont(font1, "Pixeled.ttf", 30);
	LEVEL_BANNER_POS_X = SCREEN_WIDTH * 1 / 4;
	LEVEL_BANNER_POS_Y = SCREEN_HEIGHT * 1 / 12;
	swidth_level_banner = (SCREEN_WIDTH * 1 / 2) / getSpriteWidth(levelBannerUI);
	sheight_level_banner = (SCREEN_HEIGHT * 1 / 12) / getSpriteHeight(levelBannerUI);
	LEVEL_TEXT_CONSTRAINT_X = 0.5f;
	LEVEL_TEXT_CONSTRAINT_Y = 0.2f;
	LEVEL_TEXT_POS_X = LEVEL_BANNER_POS_X + LEVEL_TEXT_CONSTRAINT_X*swidth_level_banner*al_get_bitmap_width(levelBannerUI);
	LEVEL_TEXT_POS_Y = LEVEL_BANNER_POS_Y - LEVEL_TEXT_CONSTRAINT_Y*sheight_level_banner*al_get_bitmap_height(levelBannerUI);

	loadSprite(scoreUI, "UI_Score.png");
	loadFont(font2, "Pixeled.ttf", 20);
	SCORE_POS_X = SCREEN_WIDTH * 13 / 16;
	SCORE_POS_Y = SCREEN_HEIGHT * 1 / 12;
	swidth_score = (SCREEN_WIDTH * 1 / 8) / getSpriteWidth(scoreUI);
	sheight_score = (SCREEN_HEIGHT * 1 / 12) / getSpriteHeight(scoreUI);
	SCORE_TEXT_CONSTRAINT_X = 0.97f;
	SCORE_TEXT_CONSTRAINT_Y = 0.05f;
	SCORE_TEXT_POS_X = SCORE_POS_X + SCORE_TEXT_CONSTRAINT_X*swidth_score*al_get_bitmap_width(scoreUI);
	SCORE_TEXT_POS_Y = SCORE_POS_Y + SCORE_TEXT_CONSTRAINT_Y*sheight_score*al_get_bitmap_height(scoreUI);

	loadSprite(scoreBoardUI, "UI_Scoreboard.png");
	loadFont(font3, "Pixeled.ttf", 10);
	SCOREBOARD_POS_X = SCREEN_WIDTH * 13 / 16;
	SCOREBOARD_POS_Y = SCREEN_HEIGHT * 1 / 4;
	swidth_scoreboard = (SCREEN_WIDTH * 1 / 8) / getSpriteWidth(scoreBoardUI);
	sheight_scoreboard = (SCREEN_HEIGHT * 2 / 3) / getSpriteHeight(scoreBoardUI);
	TOPSCORES_CONSTRAINT_X = 0.1f;
	TOPSCORES_CONSTRAINT_Y = 1.5f;
	TOPSCORES_POS_X = SCOREBOARD_POS_X + TOPSCORES_CONSTRAINT_X*swidth_scoreboard*al_get_bitmap_width(scoreBoardUI);
	TOPSCORES_POS_Y = SCOREBOARD_POS_X - TOPSCORES_CONSTRAINT_Y*sheight_scoreboard*al_get_bitmap_height(scoreBoardUI);
	TOPSCORES_JUMP_Y = 0.08*sheight_scoreboard*al_get_bitmap_height(scoreBoardUI);

	scoreAux = 0;
}

void UserInterface::refreshUI() {
	
}

void UserInterface::drawUI()
{
	float life_width = getSpriteWidth(life1) * swidth_inital_life;

	drawSprite(livesUI, UI_LIVES_POS_X, UI_LIVES_POS_Y, swidth_UI_lives, sheight_UI_lives);
	drawSprite(life1, UI_LIVES_POS_X, UI_LIVES_POS_Y, swidth_inital_life, sheight_initial_life);
	drawSprite(life2, UI_LIVES_POS_X + life_width, UI_LIVES_POS_Y, swidth_inital_life, sheight_initial_life);
	drawSprite(life3, UI_LIVES_POS_X + 2 * life_width, UI_LIVES_POS_Y, swidth_inital_life, sheight_initial_life);
	drawSprite(life4, UI_LIVES_POS_X + 3 * life_width, UI_LIVES_POS_Y, swidth_inital_life, sheight_initial_life);
	//	drawSprite(life3, INITIAL_LIFE_POS_X + 4 * LIFE_X_OFFSET, INITIAL_LIFE_POS_Y, swidth_inital_life, sheight_initial_life);
	drawSprite(controlsUI, CONTROLS_POS_X, CONTROLS_POS_Y, swidth_controls, sheight_controls);

	drawSprite(levelBannerUI, LEVEL_BANNER_POS_X, LEVEL_BANNER_POS_Y, swidth_level_banner, sheight_level_banner);
	drawFont(font1, al_map_rgb(0, 0, 0), LEVEL_TEXT_POS_X, LEVEL_TEXT_POS_Y, ALLIGN_CENTRE, "Level 1"); //The sprite needs to be updated

	drawSprite(scoreUI, SCORE_POS_X, SCORE_POS_Y, swidth_score, sheight_score);
	drawFont(font2, al_map_rgb(0, 0, 0), SCORE_TEXT_POS_X, SCORE_TEXT_POS_Y, ALLIGN_RIGHT, std::to_string(scoreAux));
	drawSprite(scoreBoardUI, SCOREBOARD_POS_X, SCOREBOARD_POS_Y, swidth_scoreboard, sheight_scoreboard);
	for (int i = 0; i < 10; i++)
	{
		drawFont(font3, al_map_rgb(0, 0, 0), TOPSCORES_POS_X, TOPSCORES_POS_Y+i*TOPSCORES_JUMP_Y, ALLIGN_LEFT, std::to_string(i + 1) + ". Player " + std::to_string(i + 1));
	}
}

void UserInterface::copyScore(int sc)
{
	scoreAux = sc;
}

UserInterface::~UserInterface() {
	destroySprite(life1);
	destroySprite(life2);
	destroySprite(life3);
	destroySprite(life4);
	destroySprite(life5);
	destroySprite(livesUI);
	destroySprite(scoreUI);
	destroySprite(scoreBoardUI);
	destroySprite(levelBannerUI);
	destroySprite(controlsUI);
}

//bool newGame(PARAMETERS int level, )
//{
//First we create a window

//We load the scoreboards from the PLAYER_DATAPATH

//Now we load the UI elements
/*
LIVES ----------             LEVEL X                  SCORE: XXXXX

|--------------|									  |-------------|
|			   |									  |				|
|	CONTROLS   |           MAIN LEVEL FRAME           |	 SCOREBOARD	|
|			   |									  |			    |
|--------------|									  |-------------|
*/
//We load the level progression

//We start the gameloop

//IF the game is lost the data of the current player is saved
//}

int main()
{
	//FreeConsole(); //Hides the console.

	bool done = false, draw = false;
	playerArray data;
	playerData currentPlayer;
	std::string playerName;
	ALLEGRO_DISPLAY * display = nullptr;
	ALLEGRO_TIMER *general_timer = nullptr;
	ALLEGRO_EVENT_QUEUE *event_queue = nullptr;
	ALLEGRO_KEYBOARD_STATE keyState;
	std::vector<ALLEGRO_BITMAP *> redGhost, pinkGhost, orangeGhost, blueGhost;
	ALLEGRO_SAMPLE * pacmanSong = nullptr, *pacmanFX = nullptr;
	ALLEGRO_SAMPLE_INSTANCE * songInstance = nullptr;
	ALLEGRO_COLOR back_color = al_map_rgb(25, 25, 25);
	ALLEGRO_FONT *pixeled = nullptr;


	initializeFramework(true, true, false, true, true, true, 2);
	createDisplay(display, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0, "Pacman", standard);
	initializeEvent(display, event_queue, true, true, false);

	UserInterface UI;
	Player pacman(3, "Pac-Man_AnimationSheet.png", event_queue);
	RedGhost rg();
	BlueGhost bg();
	OrangeGhost og();
	PinkGhost pg();
	Pellet pel();
	PowerUp pup();
	Level level;
	Score score;

	//First we load all the images and sounds

	loadSong(pacmanSong, "PacmanSong.ogg", songInstance, loop);
	loadSound(pacmanFX, "PacmanFX.wav");
	loadSprite(redGhost, "RedGhost_Animation.png");
	loadSprite(pinkGhost, "PinkGhost_Animation.png");
	loadSprite(orangeGhost, "OrangeGhost_Animation.png");
	loadSprite(blueGhost, "BlueGhost_Animation.png");

	loadFont(pixeled, "Pixeled.ttf", 30);
	level.LoadLevel();

	UI.drawUI();
	showScreen(back_color, INITIAL_LEVEL_POS_X, INITIAL_LEVEL_POS_Y, LEVEL_LENGTH_X, LEVEL_LENGTH_Y, SCREEN_WIDTH, SCREEN_HEIGHT);

	/*
	std::ofstream test_encrip_output;
	playerData player1, player2, player3;
	player1.name = "TEST1";
	player2.name = "Test2";
	player3.name = "Test-3";
	player1.score.SetScore(100);
	player2.score.SetScore(50);
	player3.score.SetScore(975);
	data.push_back(player1);
	data.push_back(player2);
	data.push_back(player3);

	SaveAndEncrypt(data);

	ALLEGRO_PATH *pathTest = al_get_standard_path(ALLEGRO_RESOURCES_PATH);

	al_change_directory(al_path_cstr(pathTest, '/'));
	al_destroy_path(pathTest);

	test_encrip_output.open("TEST.txt");
	data.clear();
	LoadAndDecryptFile(data);
	for (int i = 0; i < data.size(); i++)
	{
	test_encrip_output << data[i].name << " " << std::to_string(data[i].score.ReturnScore()) << '\n';
	system("pause");
	}
	system("pause");
	test_encrip_output.close();
	*/
	float x, y; //Temporal help

				//createTimer(general_timer, 30);
				//registerTimer(event_queue, general_timer);
				//startTimer(general_timer);
	pacman.StartTiming();

	while (!done) {
		ALLEGRO_EVENT events;
		waitEvent(event_queue, events);

		if (events.type == EVENT_KEY_DOWN) {
			switch (events.keyboard.keycode) {
			case KEY_RIGHT: {
				if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 1, 0)) {
					pacman.SetLastDirection(pacman.GetDirection());
					pacman.SetDirection(RIGHT);
				}
				else {
					pacman.SetNextDirection(RIGHT);
				}
			}break;
			case KEY_LEFT: {
				if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), -1, 0)) {
					pacman.SetLastDirection(pacman.GetDirection());
					pacman.SetDirection(LEFT);
				}
				else {
					pacman.SetNextDirection(LEFT);
				}
			}break;
			case KEY_UP: {
				if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 0, -1)) {
					pacman.SetLastDirection(pacman.GetDirection());
					pacman.SetDirection(UP);
				}
				else {
					pacman.SetNextDirection(UP);
				}
			}break;
			case KEY_DOWN: {
				if (pacman.movementPossible(pacman.GetPositionX(), pacman.GetPositionY(), level.GetMap(), 0, 1)) {
					pacman.SetLastDirection(pacman.GetDirection());
					pacman.SetDirection(DOWN);
				}
				else {
					pacman.SetNextDirection(DOWN);
				}
			}break;
			case KEY_ESCAPE: {
				done = true;
			}
			}
		}
		else if (events.type == EVENT_TIMER) {
			if (events.timer.source == general_timer) {
			}
			else if (events.timer.source == pacman.GetRefreshTimer()) {
				refreshLevel(level, pacman, events, score);
				UI.copyScore(score.ReturnScore());
				draw = true;
			}
		}

		if (draw) {
			UI.drawUI();
			drawLevel(level, pacman, back_color, events, SCREEN_WIDTH, SCREEN_HEIGHT);
			draw = false;
		}
	}

	destroyFramework(true, true, false, true, true, true);

	return 0;
}
