/*----------------------------------------------------------*/

#include <a_samp>
#include <td_gametext>

/*----------------------------------------------------------*/
/*
native Menu:CreateMenuRus(const title[], columns, Float:x, Float:y, Float:col1width, Float:col2width);
native AddMenuItemRus(Menu:menuid, column, const menutext[]);
native SetMenuColumnHeaderRus(Menu:menuid, column, const columnheader[]);
native GameTextForAllRus(text[], time, style);
native GameTextForPlayerRus(playerid, text[], time, style);
native DisplayTextForPlayerRus(playerid, text[], time, font, style);
*/
/*----------------------------------------------------------*/

forward GameTextRusFix(text[]);

/*---------------------------------------------------------*/

new gametext[256];

stock Menu:CreateMenuRus(title[], columns, Float:x, Float:y, Float:col1width, Float:col2width)
{
	GameTextRusFix(title);
	CreateMenu(gametext, columns, Float:x, Float:y, Float:col1width, Float:col2width);
	return 1;
}

stock AddMenuItemRus(Menu:menuid, column, menutext[])
{
	GameTextRusFix(menutext);
	AddMenuItem(Menu:menuid, column, gametext);
	return 1;
}

stock SetMenuColumnHeaderRus(Menu:menuid, column, columnheader[])
{
	GameTextRusFix(columnheader);
	SetMenuColumnHeader(Menu:menuid, column, gametext);
	return 1;
}

stock GameTextForAllRus(text[], time, style)
{
	GameTextRusFix(text);
	GameTextForAll(gametext, time, style);
	return 1;
}

stock GameTextForPlayerRus(playerid, text[], time, style)
{
	GameTextRusFix(text);
	GameTextForPlayer(playerid, gametext, time, style);
	return 1;
}

stock DisplayTextForPlayerRus(playerid, text[], time, font, style)
{
	GameTextRusFix(text);
	DisplayTextForPlayer(playerid, gametext, time, font, style);
	return 1;
}

public GameTextRusFix(text[])
{
	new length = strlen(text);
	for(new i; i < length; i++)
	{
		switch(text[i]%256)
		{
			case 'à':gametext[i] = 'a';
			case 'À':gametext[i] = 'A';
			case 'á':gametext[i] = '—';
			case 'Á':gametext[i] = '€';
			case 'â':gametext[i] = '˜';
			case 'Â':gametext[i] = '';
			case 'ã':gametext[i] = '™';
			case 'Ã':gametext[i] = '‚';
			case 'ä':gametext[i] = 'š';
			case 'Ä':gametext[i] = 'ƒ';
			case 'å':gametext[i] = 'e';
			case 'Å':gametext[i] = 'E';
			case '¸':gametext[i] = 'e';
			case '¨':gametext[i] = 'E';
			case 'æ':gametext[i] = '›';
			case 'Æ':gametext[i] = '„';
			case 'ç':gametext[i] = 'Ÿ';
			case 'Ç':gametext[i] = 'ˆ';
			case 'è':gametext[i] = 'œ';
			case 'È':gametext[i] = '…';
			case 'É':gametext[i] = '…';
			case 'é':gametext[i] = '';
			case 'ê':gametext[i] = 'k';
			case 'Ê':gametext[i] = 'K';
			case 'ë':gametext[i] = 'ž';
			case 'Ë':gametext[i] = '‡';
			case 'ì':gametext[i] = '¯';
			case 'Ì':gametext[i] = 'M';
			case 'í':gametext[i] = '®';
			case 'Í':gametext[i] = 'H';
			case 'î':gametext[i] = 'o';
			case 'Î':gametext[i] = 'O';
			case 'ï':gametext[i] = '£';
			case 'Ï':gametext[i] = 'Œ';
			case 'ð':gametext[i] = 'p';
			case 'Ð':gametext[i] = 'P';
			case 'ñ':gametext[i] = 'c';
			case 'Ñ':gametext[i] = 'C';
			case 'ò':gametext[i] = '¦';
			case 'Ò':gametext[i] = '';
			case 'ó':gametext[i] = 'y';
			case 'Ó':gametext[i] = '–';
			case 'ô':gametext[i] = '¢';
			case 'Ô':gametext[i] = '‹';
			case 'õ':gametext[i] = 'x';
			case 'Õ':gametext[i] = 'X';
			case 'ö':gametext[i] = '‰';
			case 'Ö':gametext[i] = '‰';
			case '÷':gametext[i] = '¤';
			case '×':gametext[i] = '';
			case 'ø':gametext[i] = '¥';
			case 'Ø':gametext[i] = 'Ž';
			case 'ù':gametext[i] = '¡';
			case 'Ù':gametext[i] = 'Š';
			case 'ü':gametext[i] = '©';
			case 'Ü':gametext[i] = '’';
			case 'ú':gametext[i] = '';
			case 'Ú':gametext[i] = '§';
			case 'û':gametext[i] = '¨';
			case 'Û':gametext[i] = '‘';
			case 'ý':gametext[i] = 'ª';
			case 'Ý':gametext[i] = '“';
			case 'þ':gametext[i] = '«';
			case 'Þ':gametext[i] = '”';
			case 'ÿ':gametext[i] = '¬';
			case 'ß':gametext[i] = '•';
			default: gametext[i] = text[i]%256;
		}
		gametext[length] = 0;
	}
}
