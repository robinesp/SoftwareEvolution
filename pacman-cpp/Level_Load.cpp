#include "Level_Load.h"

Level::Level()
{
	currentLevel = 1;
	first_time = true;
	LoadLevel();
}

void Level::LoadLevel()
{
	std::ifstream file;
	std::string line;
	char char_aux;
	int max_row = 0;
	tGame aux;
	std::vector<tGame> vector_aux;
	map.clear();
	vector_aux.clear();

	ALLEGRO_PATH * path = al_get_standard_path(ALLEGRO_RESOURCES_PATH);
	al_append_path_component(path, "Resources");
	al_append_path_component(path, "Maps");
	al_change_directory(al_path_cstr(path, '/'));
	al_destroy_path(path);

	file.open("Level_" + std::to_string(GetCurrentLevel()) + ".lv"); //currentLevel is an integer 
	if (file.is_open()) {
		while (!file.eof()) {
			std::getline(file, line);
			if (line != "") {
				for (int i = 0; i < line.length(); i++) {
					char_aux = line[i];
					aux.elem = CharacterTransform(char_aux);
					aux.sprite = GameElementToBitmap(aux.elem);
					vector_aux.push_back(aux);
				}
				map.push_back(vector_aux);
				vector_aux.clear();
			}
		}
	}
	file.close();
	for (int i = 0; i < map.size(); i++) {
		if (map[i].size() > max_row) {
			max_row = map[i].size();
		}
	}
	row_pixel_elem = LEVEL_LENGTH_X / max_row;
	column_pixel_elem = LEVEL_LENGTH_Y / map.size();

	for (int i = 0; i < map.size(); i++) {
		for (int j = 0; j < map[i].size(); j++) {
			map[i][j].pixel_position[0] = INITIAL_LEVEL_POS_X + j*row_pixel_elem;
			map[i][j].pixel_position[1] = INITIAL_LEVEL_POS_Y + i*column_pixel_elem;
		}
	}
}

void Level::NextLevel() {
	currentLevel++;
	LoadLevel();
}

void Level::SetMapElem(int i, int j, tGame_Element elem)
{
	destroySprite(map[i][j].sprite);
	map[i][j].sprite = nullptr;

	map[i][j].elem = elem;
	map[i][j].sprite = GameElementToBitmap(map[i][j].elem);
}

tGame_Element Level::CharacterTransform(const char& c) {
	tGame_Element aux;
	switch (c)
	{
	case 'a': aux = CLOSED_WALL;
		break;
	case 'b': aux = HORIZ_OPEN_WALL;
		break;
	case 'c': aux = VERT_OPEN_WALL;
		break;
	case 'd': aux = CLOSED_WALL_3_0DEG;
		break;
	case 'e': aux = CLOSED_WALL_3_90DEG;
		break;
	case 'f': aux = CLOSED_WALL_3_180DEG;
		break;
	case 'g': aux = CLOSED_WALL_3_270DEG;
		break;
	case 'h': aux = CLOSED_WALL_2_0DEG;
		break;
	case 'i': aux = CLOSED_WALL_2_90DEG;
		break;
	case 'j': aux = CLOSED_WALL_2_180DEG;
		break;
	case 'k': aux = CLOSED_WALL_2_270DEG;
		break;
	case 'l': aux = CLOSED_WALL_1_0DEG;
		break;
	case 'm': aux = CLOSED_WALL_1_90DEG;
		break;
	case 'n': aux = CLOSED_WALL_1_180DEG;
		break;
	case 'o': aux = CLOSED_WALL_1_270DEG;
		break;
	case 'p': aux = INTERIOR_WALL;
		break;
	case 'q': aux = BLUE_GHOST;
		break;
	case 'r': aux = RED_GHOST;
		break;
	case 's': aux = ORANGE_GHOST;
		break;
	case 't': aux = PINK_GHOST;
		break;
	case 'u': aux = CHERRY;
		break;
	case 'v': aux = PINEAPPLE;
		break;
	case 'P': aux = PLAYER;
		break;
	case '.': aux = PELLET;
		break;
	case '+': aux = POWER_UP;
		break;
	case ' ': aux = EMPTY;
		break;
	default:
		aux = MISTAKE;
	}
	return aux;
}

ALLEGRO_BITMAP* Level::GameElementToBitmap(const tGame_Element elem)
{
	ALLEGRO_BITMAP * aux = nullptr;

	ALLEGRO_PATH * path = al_get_standard_path(ALLEGRO_RESOURCES_PATH);
	al_append_path_component(path ,"Resources");
	al_append_path_component(path, "Sprites");
	al_change_directory(al_path_cstr(path, '/'));
	al_destroy_path(path);

	switch (elem)
	{
		case INTERIOR_WALL:
		{
			loadSprite(aux, "Inner_Wall.png");
		}break;
		case CLOSED_WALL:
		{
			loadSprite(aux, "Wall_Unique.png");
		}break;
		case VERT_OPEN_WALL:
		case HORIZ_OPEN_WALL:
		{
			loadSprite(aux, "Inner_Wall.png");
		}break;
		case CLOSED_WALL_1_0DEG:
		case CLOSED_WALL_1_90DEG:
		case CLOSED_WALL_1_180DEG:
		case CLOSED_WALL_1_270DEG:
		{
			loadSprite(aux, "Wall_Onesided.png");
		}break;
		case CLOSED_WALL_2_0DEG:
		case CLOSED_WALL_2_90DEG:
		case CLOSED_WALL_2_180DEG:
		case CLOSED_WALL_2_270DEG:
		{
			loadSprite(aux, "Wall_Corner.png");
		}break;
		case CLOSED_WALL_3_0DEG:
		case CLOSED_WALL_3_90DEG:
		case CLOSED_WALL_3_180DEG:
		case CLOSED_WALL_3_270DEG:
		{
			loadSprite(aux, "Wall_Corner.png");
		}break;
		case PELLET:
		{
			loadSprite(aux, "Pellet.png");
		}break;
		case POWER_UP:
		{
			loadSprite(aux, "PowerUp.png");
		}break;
		case CHERRY:
		{
			loadSprite(aux, "Cherries.png");
		}break;
		case PINEAPPLE:
		{
			loadSprite(aux, "Pineapple.png");
		}break;
		case PLAYER:
		{
			loadSprite(aux, "Life_Icon.png");
		}break;
		case RED_GHOST:
		case BLUE_GHOST:
		case PINK_GHOST:
		case ORANGE_GHOST:
		case EMPTY:
		{
			loadSprite(aux, "Empty.png");
		}break;
		default:
		{
			loadSprite(aux, "Error.png"); //Until we have an error sprite
		}
	}

	return aux;
}

float Level::AngleFromElement(const tGame_Element & aux)
{
	float angle;

	switch (aux)
	{
	case VERT_OPEN_WALL:
	case CLOSED_WALL_1_90DEG:
	case CLOSED_WALL_2_90DEG:
	case CLOSED_WALL_3_90DEG:
	{
		angle = PI / 2.0;
	}break;
	case CLOSED_WALL_1_180DEG:
	case CLOSED_WALL_2_180DEG:
	case CLOSED_WALL_3_180DEG:
	{
		angle = PI;
	}break;
	case CLOSED_WALL_1_270DEG:
	case CLOSED_WALL_2_270DEG:
	case CLOSED_WALL_3_270DEG:
	{
		angle = (3 * PI) / 2.0;
	}break;
	default:
	{
		angle = 0;
	}
	}
	return angle;
}

void Level::SetFirstTime(bool boolean) {
	first_time = boolean;
}

int Level::GetCurrentLevel() const
{
	return currentLevel;
}

int Level::GetSize(int i) const {
	if (i == -1) {
		return map.size();
	}
	else {
		return map[i].size();
	}
}

tGame_Element Level::GetElement(int i, int j) const
{
	return map[i][j].elem;
}

ALLEGRO_BITMAP * Level::GetBitmap(int i, int j) const
{
	return map[i][j].sprite;
}

float Level::GetPixelPositionX(int j) const {
	return map[0][j].pixel_position[0];
}

float Level::GetPixelPositionY(int i) const {
	return map[i][0].pixel_position[1];
}

std::vector<std::vector<tGame>> Level::GetMap() const {
	return map;
}

int Level::GetRowPixelElem() const {
	return row_pixel_elem;
}

int Level::GetColumnPixelElem() const {
	return column_pixel_elem;
}

bool Level::GetFirstTime() const {
	return first_time;
}

Level::~Level()
{
	map.clear();
}
