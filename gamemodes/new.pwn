//Catborisovv and Zuboskall

//==============================================================================
#include <a_samp>
#include <streamer>
#include <a_mysql>
#include <dc_cmd>
#include <sscanf2>
#include <foreach>
#include <fix_Kick>
#include <nex-ac>
#include <crp>
#include <discord-connector>
#include <TOTP>
#include <sampvoice>
#include <fly>

#include <afk>

#if !defined gpci
    native gpci(playerid, serial[], len);
#endif
//===============================[MySQL]========================================
#define MySQL_HOST      ""
#define MySQL_USER      ""
#define MySQL_BD        ""
#define MySQL_PASS      ""
//==============================[������]========================================
#define                         GAMEMODE                    "MDM"
#define                         HOSTNAME                    "��������� �� #1"
//==============================[Define]========================================
#define         f(                                  format(string, sizeof(string),
#define         GN(%1)                              Player[%1][pName]
#define         publics%0(%1) forward%0(%1);        public%0(%1)
#define         SPD                                 ShowPlayerDialog
#define         DSL                                 DIALOG_STYLE_LIST
#define         DSI                                 DIALOG_STYLE_INPUT
#define         DSP                                 DIALOG_STYLE_PASS
#define         DSM                                 DIALOG_STYLE_MSGBOX
#define         SCM                                 SendClientMessage
#define         SCMTA                               SendClientMessageToAll
#define         Kickk(%1)                           SetTimerEx("kick", 20, false, "i", %1)
#define         HOLDING(%0) \ ((newkeys & (%0)) == (%0))
#define          SERIAL_LENGTH                      40
#define         COLOR_RADIO                         0x69b867FF

#define         COLOR_YELLOW                        0xffff00FF

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define         SetHP                               SetPlayerHealth

#define max_health 100

#define DIALOG_STYLE_PASSWORD 3

#define AC_MAX_CODES 53
#define AC_MAX_CODE_LENGTH (3 + 1)
#define AC_MAX_CODE_NAME_LENGTH (33 + 1)

#define AC_CODE_TRIGGER_TYPE_DISABLED 0 
#define AC_CODE_TRIGGER_TYPE_WARNING 1 
#define AC_CODE_TRIGGER_TYPE_KICK 2 

#define AC_MAX_TRIGGER_TYPES 3

#define AC_GLOBAL_TRIGGER_TYPE_PLAYER 0

#pragma tabsize 0

//#define RandomEX(%0,%1) (%0+random(%1-%0))
//===============================[�����]========================================
#define                 COLOR_ASAK              0xe36565FF
#define                 COLOR_WHITE             0xFFFFFFFF
#define                 COLOR_RED               0xFF0000FF
#define                 COLOR_BLUE              0x0d95e5AA
#define                 COLOR_GREY              0xAFAFAFAA
#define                 COLOR_ADMINCHAT         0x8fbedb00
#define                 COLOR_BLOCK             0xf3573cFF
#define                 COLOR_TOMATO            0xFF6347FF

#define COLOR_LIGHTYELLOW       0xFFFF99FF
//================================[New]=========================================
new zonals;
//new zone;
new ConnectMySQL;
new bool:pCBugging[MAX_PLAYERS];
//new pCBugging[MAX_PLAYERS];
new ptmCBugFreezeOver[MAX_PLAYERS];
new ptsLastFiredWeapon[MAX_PLAYERS];
new locvw[MAX_PLAYERS];
new mpvw[MAX_PLAYERS];
new getherevw[MAX_PLAYERS];

new KostiName[MAX_PLAYERS];
new KostiMoney[MAX_PLAYERS];

new Text:mdm_logo_TD;

new onlinetimer[MAX_PLAYERS];

enum pInfo
{
    pName[MAX_PLAYER_NAME],
    MUTE,
    VMUTE,
    BAN,
    pLevel,
    pPass[21],
    Spectating[2],
    pSex,
    pSkin,
    ADMIN,
    REPORTS,
    LASTDAY,
    LASTMOUNTH,
    LASTYEAR,
    ID,
    malinki,
    malplus,
    online,
    HideMe,
}

enum dialog
{
    dialog_playerclick,
    dialog_adminsettings
}

new Player[MAX_PLAYERS][pInfo];
new Login[MAX_PLAYERS];

new AVeh[MAX_PLAYERS];

new bool: mp;
new Float: tpmp[3];

new PlayerText:textinfo_TD_PTD[MAX_PLAYERS][5];
new UpdateSpecTimer[MAX_PLAYERS];

new SV_LSTREAM:lstream[MAX_PLAYERS] = { SV_NULL, ... };

new CaptZone;
//==============================[������]========================================
main() return true;

// Stock

static const stock GSName[8][10] =
{
    "�����",
    "NGM",
    "JRGM",
    "GM",
    "GM+",
    "LGM",
    "SGM",
    "DEV"
};


stock TogglePlayerOnMap(playerid, visible) SetPlayerColor(playerid,(GetPlayerColor(playerid) | 0xFF) - (visible ? 0x00 : 0xFF));

stock SendAdminMessage(color, str[])
{
    foreach(new i: Player)
    {
        if(Player[i][ADMIN] >= 1)
        {
            SendClientMessage(i, color, str);
        }
    }
    return true;
}


stock SendRadioMessage(color, str[], org)
{
    foreach(new i: Player)
    {
        if(Player[i][pSex] == org)
        {
            SendClientMessage(i, color, str);
        }
    }
    return 1;
}

stock SetPlayerMoney(playerid, money)
{
        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid, money);
}

stock MysqlUpdatePlayerInt(playerid, field[], data[])
{
    new Query[128];
    format(Query, sizeof(Query), "UPDATE `Accounts` SET %s = '%i' WHERE id = '%i' LIMIT 1", field, data, Player[playerid][ID]);
    return mysql_tquery(ConnectMySQL, Query, "", "");
}

stock ResetPlayerVariables(playerid)
{
    // ** GENERAL

    pCBugging[playerid] = false;

    // ** TIMERS

    KillTimer(ptmCBugFreezeOver[playerid]);

    // ** TIMESTAMPS

    ptsLastFiredWeapon[playerid] = 0;
    return 1;
}


stock gpname(playerid)
{
        new Name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, Name, sizeof Name);
        return Name;
}

stock ProxDetector(playerid, Float:radi, string[], col1,col2,col3,col4,col5)
{
    new Float: Pos[3], Float: Radius;
    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
    foreach(new i : Player)
    {
        Radius = GetPlayerDistanceFromPoint(i, Pos[0], Pos[1], Pos[2]);
        if (Radius < radi / 16) SendClientMessage(i, col1, string);
        else if(Radius < radi / 8) SendClientMessage(i, col2, string);
        else if(Radius < radi / 4) SendClientMessage(i, col3, string);
        else if(Radius < radi / 2) SendClientMessage(i, col4, string);
        else if(Radius < radi) SendClientMessage(i, col5, string);
    }
    return true;
}

//==============================[Public]========================================
forward rweather();
forward clock();

public SV_VOID:OnPlayerActivationKeyPress(
    SV_UINT:playerid,
    SV_UINT:keyid
) {
    if (keyid == 0x58 && lstream[playerid])
	{
		SvAttachSpeakerToStream(lstream[playerid], playerid);
		SetPlayerChatBubble(playerid, "�������...", 0x6680a7FF, 20.0, 999999999);
	}
}

public SV_VOID:OnPlayerActivationKeyRelease(
    SV_UINT:playerid,
    SV_UINT:keyid
) {
    if (keyid == 0x58 && lstream[playerid])
	{
		SvDetachSpeakerFromStream(lstream[playerid], playerid);
		SetPlayerChatBubble(playerid, "", -1, 20, 3000);
	}
}

forward PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z);
public PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        tempposx = (oldposx -x);
        tempposy = (oldposy -y);
        tempposz = (oldposz -z);
        if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
        {
            return 1;
        }
    }
    return 0;
}

forward CBugFreezeOver(playerid);
public CBugFreezeOver(playerid)
{
    TogglePlayerControllable(playerid, true);

    pCBugging[playerid] = false;
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys == 1 || PRESSED(1))
    {
            new Weap[2];
            GetPlayerWeaponData(playerid, 4, Weap[0], Weap[1]);
            SetPlayerArmedWeapon(playerid, Weap[0]);
    }
    if(!pCBugging[playerid] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || !pCBugging[playerid] && GetPlayerState(playerid) == 1)
    {
        if(PRESSED(KEY_FIRE))
        {
            switch(GetPlayerWeapon(playerid))
            {
                case WEAPON_DEAGLE, WEAPON_SHOTGUN, WEAPON_SNIPER:
                {
                    ptsLastFiredWeapon[playerid] = gettime();
                }
            }
        }
        else if(PRESSED(KEY_CROUCH))
        {
            if((gettime() - ptsLastFiredWeapon[playerid]) < 1)
            {
                TogglePlayerControllable(playerid, false);

                pCBugging[playerid] = true;

                //GameTextForPlayer(playerid, "~r~~h~DON'T C-BUG!", 3000, 4);

                KillTimer(ptmCBugFreezeOver[playerid]);
                ptmCBugFreezeOver[playerid] = SetTimerEx("CBugFreezeOver", 1500, false, "i", playerid);
            }
    }
        if(GetPVarInt(playerid, "Animation") == 1)
        {
                    ClearAnimations(playerid);
                    SetPlayerSpecialAction(playerid, 0);
                    ApplyAnimation(playerid,"PED","IDLE_tired",4.1,0,1,1,0,1);
                    DeletePVar(playerid,"Animation");
                    //TextDrawHideForPlayer(playerid, AnimDraw);
                    return 1;
        }
    }
    if(newkeys == KEY_SPRINT)
    {
        if(GetPVarInt(playerid, "SET_ADM_POS") == 1)
        {
                SetPlayerInterior(playerid,GetPlayerInterior(Player[playerid][Spectating][0]));
                SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(Player[playerid][Spectating][0]));
                TogglePlayerSpectating(playerid, 1);
                if(IsPlayerInAnyVehicle(Player[playerid][Spectating][0]))
                {
                    new carid = GetPlayerVehicleID(Player[playerid][Spectating][0]);
                    PlayerSpectateVehicle(playerid, carid);
                }
                else PlayerSpectatePlayer(playerid, Player[playerid][Spectating][0]);
        }
    }
    return 1;
}

public OnPlayerText(playerid, text[])
{
        if(Player[playerid][MUTE] == 0)
        {
                ApplyAnimation(playerid,"PED","IDLE_chat",4.1,0,1,1,1,1);
                SetTimerEx("RukiOff", 1400, 0, "d", playerid);
                new string[144];
                if(strlen(text) < 107)
                {
                    if(IsPlayerFlying(playerid) != 0)
                    {
	                    format(string, sizeof(string), "[%s #%d] %s[%d]: %s",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid, text);
	                    SendAdminMessage(COLOR_BLUE, string);
					}
					else
					{
	                    if(GetPVarInt(playerid, "SET_ADM_POS") == 1)
	                    {
	                        format(string, sizeof(string), "[%s #%d] %s[%d]: %s",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid, text);
	                        SendAdminMessage(COLOR_BLUE, string);
	                    }
	                    else
	                    {
	                        if(Player[playerid][HideMe] == 1)
	                        {
	                                    format(string, sizeof(string), "������� ������ #%d: {FFFFFF}%s", Player[playerid][ID], text);
	                                    ProxDetector(playerid, 20.0, string, 0xDD3366FF, 0xDD3366FF, 0xDD3366FF, 0xDD3366FF, 0xDD3366FF);
	                                    SetPlayerChatBubble(playerid, text, 0x6680a7FF, 20.0, 3000);
	                        }
	                        else
	                        {
	                        if(Player[playerid][malplus] == 0)
	                        {
	                                if(Player[playerid][pSex] == 1)
	                                {
	                                    format(string, sizeof(string), "- %s {66CCFF}(%s)[%d]", text, gpname(playerid), playerid);
	                                    ProxDetector(playerid, 20.0, string, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
	                                    SetPlayerChatBubble(playerid, text, 0x6680a7FF, 20.0, 3000);
	                                }
	                                if(Player[playerid][pSex] == 2)
	                                {
	                                    format(string, sizeof(string), "- %s {663399}(%s)[%d]", text, gpname(playerid), playerid);
	                                    ProxDetector(playerid, 20.0, string, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
	                                    SetPlayerChatBubble(playerid, text, 0x6680a7FF, 20.0, 3000);
	                                }
	                                if(Player[playerid][pSex] == 3)
	                                {
	                                    format(string, sizeof(string), "- %s {339933}(%s)[%d]", text, gpname(playerid), playerid);
	                                    ProxDetector(playerid, 20.0, string, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
	                                    SetPlayerChatBubble(playerid, text, 0x6680a7FF, 20.0, 3000);
	                                }
	                        }
	                        else
	                        {
	                            if(Player[playerid][pSex] == 1)
	                            {
	                                format(string, sizeof(string), "- %s {66CCFF}(%s)[%d] {DD3366}[�+]", text, gpname(playerid), playerid);
	                                ProxDetector(playerid, 20.0, string, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
	                                SetPlayerChatBubble(playerid, text, 0x6680a7FF, 20.0, 3000);
	                            }
	                            if(Player[playerid][pSex] == 2)
	                            {
	                                format(string, sizeof(string), "- %s {663399}(%s)[%d] {DD3366}[�+]", text, gpname(playerid), playerid);
	                                ProxDetector(playerid, 20.0, string, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
	                                SetPlayerChatBubble(playerid, text, 0x6680a7FF, 20.0, 3000);
	                            }
	                            if(Player[playerid][pSex] == 3)
	                            {
	                                format(string, sizeof(string), "- %s {339933}(%s)[%d] {DD3366}[�+]", text, gpname(playerid), playerid);
	                                ProxDetector(playerid, 20.0, string, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
	                                SetPlayerChatBubble(playerid, text, 0x6680a7FF, 20.0, 3000);
	                            }
	                        }
	                    }
	                }
	            }
	        }
		}
        else
        {
            SCM(playerid, COLOR_WHITE, "��� ������������ ������� ��������");
            SetPlayerChatBubble(playerid, "������� ��� ������������", COLOR_BLOCK, 20.0, 3000);
            return 0;
        }
        return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(onlinetimer[playerid]);

	if(GetPVarInt(playerid, "DuelStart") != 0)
	{
	    SetPVarInt(GetPVarInt(playerid, "DuelRival"), "DuelStart", 0);
	    SetPVarInt(GetPVarInt(playerid, "DuelRival"), "DuelStart", 0);
	    
		SpawnPlayer(GetPVarInt(playerid, "DuelRival"));
		
		new string1[144];
		format(string1, sizeof(string1), "[DUEL] %s[%d] > %s[%d]: {dd4b0e}����� �����������", gpname(GetPVarInt(playerid, "DuelRival")), GetPVarInt(playerid, "DuelRival"), gpname(playerid), playerid);
		SendAdminMessage(COLOR_YELLOW, string1);
	}

    if (lstream[playerid]) {
        SvDeleteStream(lstream[playerid]);
        lstream[playerid] = SV_NULL;
    }
    if(GetPVarInt(playerid, "Kick") != 0) KillTimer(GetPVarInt(playerid, "Kick"));
    if(GetPVarInt(playerid,"CREATEVEH") > 0)
    {
         DestroyVehicle(GetPVarInt(playerid,"CREATEVEH"));
         DeletePVar(playerid,"CREATEVEH");
    }
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(GetPVarInt(i, "SET_ADM_POS") == 1 && Player[i][Spectating][0] == playerid)
        {
                        SetPlayerHealth(i, 100);
                        
                        new string[144];
                        format(string, sizeof(string), "~r~����� �����");
                        GameTextForPlayer(i, string, 1000, 3);
                      
                        PlayerTextDrawHide(i, textinfo_TD_PTD[i][0]);
                        PlayerTextDrawHide(i, textinfo_TD_PTD[i][1]);
                        PlayerTextDrawHide(i, textinfo_TD_PTD[i][2]);
                        PlayerTextDrawHide(i, textinfo_TD_PTD[i][3]);
                        PlayerTextDrawHide(i, textinfo_TD_PTD[i][4]);

                        Player[i][Spectating][0] = -1;
                        KillTimer(UpdateSpecTimer[i]);
                        
                        TogglePlayerSpectating(i, false);
                        
                        SetPVarFloat(i, "SET_ADM_POS", 0);

                        SetPlayerPos(i, GetPVarFloat(i, "re_X"), GetPVarFloat(i, "re_Y"), GetPVarFloat(i, "re_Z"));
                        SetPlayerInterior(i, GetPVarInt(i, "re_int"));
                        SetPlayerVirtualWorld(i, GetPVarInt(i, "re_virt"));
        }
   }

	if(Player[playerid][ADMIN] >= 1)
	{
		if(Player[playerid][ADMIN] < 6)
		{
			new string_adm[144];
   			switch(reason)
		    {
		        case 0: format(string_adm,sizeof(string_adm),"[%s #%d] %s[%d] ����� �� ����. ������� ������: �������/crash",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid);
		        case 1: format(string_adm,sizeof(string_adm),"[%s #%d] %s[%d] ����� �� ����. ������� ������: �����",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid);
		        case 2: format(string_adm,sizeof(string_adm),"[%s #%d] %s[%d] ����� �� ����. ������� ������: Kick",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid);
		    }
		  	SendAdminMessage(COLOR_ADMINCHAT, string_adm);
  		}
	}

    Player[playerid][HideMe] = 0;
    //TogglePlayerSpectating(playerid,1);
    ResetPlayerVariables(playerid);
    return 1;
}

forward CameraLookConnect(playerid);
public CameraLookConnect(playerid)
{
    SetPlayerPos(playerid, 1448.1584,-1274.9492,15.8380);
    SetPlayerCameraPos(playerid,1448.1584,-1274.9492,15.8380);
    SetPlayerCameraLookAt(playerid, 1499.4703,-1230.2650,12.6845);
	return true;
}

public OnPlayerConnect(playerid)
{
    new string[85];
    GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
    f("SELECT `Level` FROM `Accounts` WHERE `Name` = '%s'", GN(playerid));
    mysql_function_query(ConnectMySQL, string, true, "PlayerRegition","d", playerid);
    //mysql_tquery(ConnectMySQL, string, "PlayerRegition", "d", playerid);
    TogglePlayerSpectating(playerid, true);
    SetTimerEx("CameraLookConnect", 2000, false, "i", playerid);
    Clear(playerid);

	locvw[playerid] = 0;

	GangZoneShowForPlayer(playerid, CaptZone, 0xFF000055);

    SendClientMessage(playerid,0x3399FF00,"����� ���������� �� Malinovka DM!");
    SendClientMessage(playerid, COLOR_LIGHTYELLOW, "��������� ������ ������� ������, ���������� ���������...");
    SendClientMessage(playerid, COLOR_LIGHTYELLOW, "����������� ���������� ��������� ����� - ������� (����.) X, ��������� ���������� ���� - (����.) ������� F11");

    SetPlayerColor(playerid, COLOR_GREY);

    KostiName[playerid] = 999;
    KostiMoney[playerid] = 0;
    
    Player[playerid][ADMIN] = 0;

    if (!SvGetVersion(playerid)) SendClientMessage(playerid, -1, "���� ����������, �������������� ����");
    else if (!SvHasMicro(playerid)) SendClientMessage(playerid, -1, "�������� �� ���������");
    else if ((lstream[playerid] = SvCreateDLStreamAtPlayer(30.0, SV_INFINITY, playerid)))
    {
        SvAddKey(playerid, 0x58);
    }

    if(!fexist("SerialBans.txt")) return 1;
    new serialid[164];
    gpci(playerid, serialid, sizeof(serialid));
    new File:sfile = fopen("SerialBans.txt", io_read);
    Player[playerid][HideMe] = 0;
    if(sfile)
    {
        new banstr[512];
        while(fread(sfile, banstr))
        {
            if(strfind(banstr, serialid) != -1)
            {
                new dtext[144];
                format(dtext,sizeof(dtext), "{FFFFFF}��� ������� ������������, ����� �� �� ������� ������ �� ������� MDM.\n���� �� �������, ��� ��������� ������ �� �����, ���������� � ���. ��������� (vk.me/malinovkadm).\n\n����� ��������: {FFFF99}%d\n{FFFFFF}������� ����������: {FFFF99}Automatic ban", Player[playerid][ID]);
                ShowPlayerDialog(playerid, 9823, DIALOG_STYLE_INPUT, "{EE3366}���...", dtext, "�������", "������");
                Kick(playerid);
            }
        }
        fclose(sfile);
    }

    //new string[144];
            
    //Create3DTextLabel("������� ��� ���������� Catborisovv\n��� ��������� Zuboskal\n\n������� ���", 0x3cf078FF, 1505.6831,-1235.1724,13.6261, 15, 0, 1);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
            if(!IsPlayerConnected(i))continue;
            if(Player[i][HideMe] == 1)SetPlayerMarkerForPlayer(playerid,i, 0xFF000000),ShowPlayerNameTagForPlayer(playerid, i, false);
    }

    textinfo_TD_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 6.5445, 405.2496, "info"); // �����
    PlayerTextDrawLetterSize(playerid, textinfo_TD_PTD[playerid][0], 0.1769, 0.8824);
    PlayerTextDrawAlignment(playerid, textinfo_TD_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, textinfo_TD_PTD[playerid][0], -1);
    PlayerTextDrawSetOutline(playerid, textinfo_TD_PTD[playerid][0], 1);
    PlayerTextDrawBackgroundColor(playerid, textinfo_TD_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, textinfo_TD_PTD[playerid][0], 2);
    PlayerTextDrawSetProportional(playerid, textinfo_TD_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, textinfo_TD_PTD[playerid][0], 0);

    textinfo_TD_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 6.5445, 412.2499, "info_2"); // �����
    PlayerTextDrawLetterSize(playerid, textinfo_TD_PTD[playerid][1], 0.1786, 0.9066);
    PlayerTextDrawAlignment(playerid, textinfo_TD_PTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, textinfo_TD_PTD[playerid][1], -1);
    PlayerTextDrawSetOutline(playerid, textinfo_TD_PTD[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, textinfo_TD_PTD[playerid][1], 255);
    PlayerTextDrawFont(playerid, textinfo_TD_PTD[playerid][1], 2);
    PlayerTextDrawSetProportional(playerid, textinfo_TD_PTD[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, textinfo_TD_PTD[playerid][1], 0);

    textinfo_TD_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 6.5445, 419.8330, "info_3"); // �����
    PlayerTextDrawLetterSize(playerid, textinfo_TD_PTD[playerid][2], 0.1774, 0.8766);
    PlayerTextDrawAlignment(playerid, textinfo_TD_PTD[playerid][2], 1);
    PlayerTextDrawColor(playerid, textinfo_TD_PTD[playerid][2], -1);
    PlayerTextDrawSetOutline(playerid, textinfo_TD_PTD[playerid][2], -1);
    PlayerTextDrawBackgroundColor(playerid, textinfo_TD_PTD[playerid][2], 255);
    PlayerTextDrawFont(playerid, textinfo_TD_PTD[playerid][2], 2);
    PlayerTextDrawSetProportional(playerid, textinfo_TD_PTD[playerid][2], 1);
    PlayerTextDrawSetShadow(playerid, textinfo_TD_PTD[playerid][2], 0);

    textinfo_TD_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 6.5445, 426.8334, "info_4"); // �����
    PlayerTextDrawLetterSize(playerid, textinfo_TD_PTD[playerid][3], 0.1573, 0.8999);
    PlayerTextDrawAlignment(playerid, textinfo_TD_PTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, textinfo_TD_PTD[playerid][3], -1);
    PlayerTextDrawSetOutline(playerid, textinfo_TD_PTD[playerid][3], 1);
    PlayerTextDrawBackgroundColor(playerid, textinfo_TD_PTD[playerid][3], 255);
    PlayerTextDrawFont(playerid, textinfo_TD_PTD[playerid][3], 2);
    PlayerTextDrawSetProportional(playerid, textinfo_TD_PTD[playerid][3], 1);
    PlayerTextDrawSetShadow(playerid, textinfo_TD_PTD[playerid][3], 0);

    textinfo_TD_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 6.5445, 434.4167, "info_5"); // �����
    PlayerTextDrawLetterSize(playerid, textinfo_TD_PTD[playerid][4], 0.1619, 0.9349);
    PlayerTextDrawAlignment(playerid, textinfo_TD_PTD[playerid][4], 1);
    PlayerTextDrawColor(playerid, textinfo_TD_PTD[playerid][4], -1);
    PlayerTextDrawSetOutline(playerid, textinfo_TD_PTD[playerid][4], 1);
    PlayerTextDrawBackgroundColor(playerid, textinfo_TD_PTD[playerid][4], 255);
    PlayerTextDrawFont(playerid, textinfo_TD_PTD[playerid][4], 2);
    PlayerTextDrawSetProportional(playerid, textinfo_TD_PTD[playerid][4], 1);
    PlayerTextDrawSetShadow(playerid, textinfo_TD_PTD[playerid][4], 0);

    RemoveBuildingForPlayer(playerid, 5356, 1417.6899, -1268.0900, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5357, 1414.2200, -1441.6899, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5358, 1379.7800, -1632.3400, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5359, 1307.2500, -1685.3700, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5360, 1275.0500, -1740.1400, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5361, 1213.1801, -1817.6700, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5362, 1160.9700, -1917.1899, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5363, 1238.6100, -2011.6200, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5365, 1233.5500, -2098.2000, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5364, 1047.6000, -2078.5300, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5366, 994.1860, -2150.2600, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5378, 1417.6899, -1268.0900, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5379, 1414.2200, -1441.6899, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5380, 1379.7800, -1632.3400, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5381, 1307.2500, -1685.3700, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5382, 1275.0500, -1740.1400, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5383, 1213.1801, -1817.6700, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5384, 1160.9700, -1917.1899, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5385, 1238.6100, -2011.6200, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5386, 1233.5500, -2098.2000, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5387, 1047.6000, -2078.5300, 25.0000, 0.25);
    RemoveBuildingForPlayer(playerid, 5389, 994.1860, -2150.2600, 25.0000, 0.25);
    return true;
}

forward UpdateSpec(playerid);
public UpdateSpec(playerid)
{
        new string[256];
        
        new Float:X, Float:Y, Float:Z;
        GetPlayerPos(Player[playerid][Spectating][0], X, Y, Z);
        
        format(string,sizeof(string),"%s(%d) (#%d)", gpname(Player[playerid][Spectating][0]), Player[playerid][Spectating][0], Player[Player[playerid][Spectating][0]][ID]);
        PlayerTextDrawSetString(playerid, textinfo_TD_PTD[playerid][0], string);
        format(string,sizeof(string),"O��A��: �A");
        PlayerTextDrawSetString(playerid, textinfo_TD_PTD[playerid][1], string);
        format(string,sizeof(string),"����: %d",GetPlayerPing(Player[playerid][Spectating][0]));
        PlayerTextDrawSetString(playerid, textinfo_TD_PTD[playerid][2], string);
        format(string,sizeof(string),"�O�����: %d, %d, %d", Float:X, Float:Y, Float:Z);
        PlayerTextDrawSetString(playerid, textinfo_TD_PTD[playerid][3], string);
        format(string,sizeof(string),"B�P�YA����� M�P: %d (���EP�EP: %d)", GetPlayerVirtualWorld(Player[playerid][Spectating][0]), GetPlayerInterior(Player[playerid][Spectating][0]));
        PlayerTextDrawSetString(playerid, textinfo_TD_PTD[playerid][4], string);
        return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
    if(Player[forplayerid][HideMe] == 1) return ShowPlayerNameTagForPlayer(playerid, forplayerid, false);
    return true;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
        new string[206];
        switch(dialogid)
        {
        case 3128:
        {
        	if(!response) return 1;
        	if(response)
        	{
        	    SCM(playerid, -1, "�� ������� ������� � �����, �������� ����");
        	    SCM(playerid, -1, "����� ��������� ����� {CCCCCC}/duelstop");
        	    
        	    SetPVarInt(playerid, "DuelRival", GetPVarInt(playerid, "DuelRivalDialog"));
				SetPVarInt(GetPVarInt(playerid, "DuelRivalDialog"), "DuelRival", playerid);
        	    
        	    SetPVarInt(GetPVarInt(playerid, "DuelRival"), "DuelStart", 1);
        	    SetPVarInt(playerid, "DuelStart", 1);
        	    
        	    SCM(GetPVarInt(playerid, "DuelRival"), -1, "����� ��������� ����� {CCCCCC}/duelstop");
        	    
				SetPlayerVirtualWorld(GetPVarInt(playerid, "DuelRival"), playerid+200);
				SetPlayerVirtualWorld(playerid, playerid+200);
				
				SetPlayerPos(GetPVarInt(playerid, "DuelRival"), 1489.0593,-1263.4598,13.2997);
				SetPlayerPos(playerid, 1488.5297,-1219.5250,12.1295);
				
				SetPlayerFacingAngle(GetPVarInt(playerid, "DuelRival"), 358.3782);
				SetPlayerFacingAngle(playerid, 177.7348);
				
                new string1[144];
                format(string1, sizeof(string1), "[DUEL] %s[%d] > %s[%d]: {2ec35a}����� ��������", gpname(GetPVarInt(playerid, "DuelRival")), GetPVarInt(playerid, "DuelRival"), gpname(playerid), playerid);
                SendAdminMessage(COLOR_YELLOW, string1);
        	}
        }
        case 5213:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������ ������ %s. �������: ������ (�. 1.1)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);
                    TogglePlayerSpectating(GetPVarInt(playerid, "PrisonID"),1);
                    Kick(GetPVarInt(playerid, "PrisonID"));
                }
                case 1:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������ ������ %s. �������: ������ (�. 1.2)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);
                    TogglePlayerSpectating(GetPVarInt(playerid, "PrisonID"),1);
                    Kick(GetPVarInt(playerid, "PrisonID"));
                }
                case 2:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������ ������ %s. �������: ����� �� ������� ���� (�. 1.3)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);
                    TogglePlayerSpectating(GetPVarInt(playerid, "PrisonID"),1);
                    Kick(GetPVarInt(playerid, "PrisonID"));
                }
                case 3:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ������� %s ��������. �������: ���� (�. 1.5)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    new Query[128];
                    format(Query, sizeof(Query), "UPDATE `Accounts` SET ban = '1' WHERE name = '%s' LIMIT 1", Player[GetPVarInt(playerid, "PrisonID")][pName]);
                    mysql_tquery(ConnectMySQL, Query, "", "");
                    
                    TogglePlayerSpectating(GetPVarInt(playerid, "PrisonID"),1);
                    Kick(GetPVarInt(playerid, "PrisonID"));
                }
                case 4:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ������� %s ��������. �������: ����� �� (�. 1.8)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    new Query[128];
                    format(Query, sizeof(Query), "UPDATE `Accounts` SET ban = '1' WHERE name = '%s' LIMIT 1", Player[GetPVarInt(playerid, "PrisonID")][pName]);
                    mysql_tquery(ConnectMySQL, Query, "", "");

                    TogglePlayerSpectating(GetPVarInt(playerid, "PrisonID"),1);
                    Kick(GetPVarInt(playerid, "PrisonID"));
                }
                case 5:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ������� %s ��������. �������: ����������� �� (�. 1.11)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    new Query[128];
                    format(Query, sizeof(Query), "UPDATE `Accounts` SET ban = '1' WHERE name = '%s' LIMIT 1", Player[GetPVarInt(playerid, "PrisonID")][pName]);
                    mysql_tquery(ConnectMySQL, Query, "", "");

                    TogglePlayerSpectating(GetPVarInt(playerid, "PrisonID"),1);
                    Kick(GetPVarInt(playerid, "PrisonID"));
                }
                case 6:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��� %s �� 120 ���. �������: ������ (�. 2.5)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);
                    
                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][MUTE] = 120*60;
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "mute", Player[GetPVarInt(playerid, "PrisonID")][MUTE]);
                }
                case 7:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��� %s �� 120 ���. �������: ����������� (�. 2.5)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][MUTE] = 120*60;
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "mute", Player[GetPVarInt(playerid, "PrisonID")][MUTE]);
                }
                case 8:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��� %s �� 180 ���. �������: ������� (�. 2.6)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][MUTE] = 180*60;
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "mute", Player[GetPVarInt(playerid, "PrisonID")][MUTE]);
                }
                case 9:
                {
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��������� ��� %s �� 60 ���. �������: ������ (�. 2.9)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][VMUTE] = 60*60;
                    SvMutePlayerEnable(GetPVarInt(playerid, "PrisonID"));
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "vmute", Player[GetPVarInt(playerid, "PrisonID")][VMUTE]);
                }
                case 10:
				{
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��������� ��� %s �� 60 ���. �������: ������������ ��������� (�. 2.10)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][VMUTE] = 60*60;
                    SvMutePlayerEnable(GetPVarInt(playerid, "PrisonID"));
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "vmute", Player[GetPVarInt(playerid, "PrisonID")][VMUTE]);
				}
				case 11:
				{
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��������� ��� %s �� 5 ���. �������: ��������� �������� (�. 2.11)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][VMUTE] = 5*60;
                    SvMutePlayerEnable(GetPVarInt(playerid, "PrisonID"));
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "vmute", Player[GetPVarInt(playerid, "PrisonID")][VMUTE]);
				}
				case 12:
				{
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��������� ��� %s �� 120 ���. �������: ����������� (�. 2.12)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][VMUTE] = 120*60;
                    SvMutePlayerEnable(GetPVarInt(playerid, "PrisonID"));
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "vmute", Player[GetPVarInt(playerid, "PrisonID")][VMUTE]);
				}
				case 13:
				{
                    new string1[144];
                    format(string1, sizeof(string1), "������� ������ #%d ������������ ��������� ��� %s �� 180 ���. �������: ���������� ������ (�. 2.13)", Player[playerid][ID], gpname(GetPVarInt(playerid, "PrisonID")));
                    SCMTA(COLOR_BLOCK, string1);

                    SCM(GetPVarInt(playerid, "PrisonID"), -1, "����� ������ ����� �� ����� ���������� ���������� ����, ������� \"/time\"");
                    Player[GetPVarInt(playerid, "PrisonID")][VMUTE] = 180*60;
                    SvMutePlayerEnable(GetPVarInt(playerid, "PrisonID"));
                    MysqlUpdatePlayerInt(GetPVarInt(playerid, "PrisonID"), "vmute", Player[GetPVarInt(playerid, "PrisonID")][VMUTE]);
				}
            }
        }
        case 2112:
        {
            if(!response) return 1;
        }
        case 9184:
        {
            if (!response) return 1;

            switch(listitem)
            {
                case 0:
                {
                    if(Player[playerid][malinki] < 390)
                    {
                        SCM(playerid, COLOR_WHITE, "�� ����� ����� ������������ �������.");
                    }
                    else
                    {
                        SCM(playerid, 0x3377CCFF, "�� ��������� ���� ���������� � �� �� 390 ���.");
                        SetPlayerSkin(playerid, 287);
                        
                        new Qwery[144];
                        format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `Skin` = '287' WHERE `id` = '%d'", Player[playerid][pName]);
                        mysql_query(ConnectMySQL, Qwery, false);
                        
                        SetPlayerSkin(playerid, 287);
                        
                        GivePlayerMoney(playerid, -390);
                        Player[playerid][malinki] = GetPlayerMoney(playerid);
                        Player[playerid][pSkin] = 287;
                        
                        new Qwery1[144];
                        format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][malinki], Player[playerid][ID]);
                        mysql_query(ConnectMySQL, Qwery1, false);
                    }
                }
                case 1:
                {
                    if(Player[playerid][malinki] < 200)
                    {
                        SCM(playerid, COLOR_WHITE, "�� ����� ����� ������������ �������.");
                    }
                    else
                    {
                        SCM(playerid, 0x3377CCFF, "�� ��������� ���� ������� ��������� �� 200 ���.");
                        SetPlayerSkin(playerid, 120);

                        new Qwery[144];
                        format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `Skin` = '120' WHERE `id` = '%d'", Player[playerid][ID]);
                        mysql_query(ConnectMySQL, Qwery, false);

                        SetPlayerSkin(playerid, 120);

                        GivePlayerMoney(playerid, -200);
                        Player[playerid][malinki] = GetPlayerMoney(playerid);
                        Player[playerid][pSex] = 2;
                        Player[playerid][pSkin] = 120;

                        new Qwery1[144];
                        format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][ID], Player[playerid][malinki]);
                        mysql_query(ConnectMySQL, Qwery1, false);
                        
                        new Qwery2[144];
                        format(Qwery2, sizeof(Qwery2), "UPDATE `Accounts` SET `Sex` = '2' WHERE `id` = '%d'", Player[playerid][ID]);
                        mysql_query(ConnectMySQL, Qwery2, false);
                    }
                }
                case 2:
                {
                        if(Player[playerid][malinki] < 200)
                        {
                                SCM(playerid, COLOR_WHITE, "�� ����� ����� ������������ �������.");
                        }
                        else
                        {
                            SCM(playerid, 0x3377CCFF, "�� ��������� ���� ������� ������ �� 200 ���.");
                            SetPlayerSkin(playerid, 115);

                            new Qwery[144];
                            format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `Skin` = '115' WHERE `id` = '%d'", Player[playerid][ID]);
                            mysql_query(ConnectMySQL, Qwery, false);

                            SetPlayerSkin(playerid, 115);

                            GivePlayerMoney(playerid, -200);
                            Player[playerid][malinki] = GetPlayerMoney(playerid);
                            Player[playerid][pSex] = 1;
                            Player[playerid][pSkin] = 115;

                            new Qwery1[144];
                            format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][ID], Player[playerid][malinki]);
                            mysql_query(ConnectMySQL, Qwery1, false);
                            
                            new Qwery2[144];
                            format(Qwery2, sizeof(Qwery2), "UPDATE `Accounts` SET `Sex` = '1' WHERE `id` = '%d'", Player[playerid][ID]);
                            mysql_query(ConnectMySQL, Qwery2, false);
                        }
                    }
                    case 3:
                    {
                        if(Player[playerid][malinki] < 390)
                        {
                                SCM(playerid, COLOR_WHITE, "�� ����� ����� ������������ �������.");
                        }
                        else
                        {
                            SCM(playerid, 0x3377CCFF, "�� ��������� ��������� plus.");
                            Player[playerid][malplus] = 1;

                            GivePlayerMoney(playerid, -200);
                            Player[playerid][malinki] = GetPlayerMoney(playerid);

                            new Qwery1[144];
                            format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malplus` = '1' WHERE `id` = '%d'", Player[playerid][ID]);
                            mysql_query(ConnectMySQL, Qwery1, false);

                            new Qwery[144];
                            format(Qwery1, sizeof(Qwery), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][ID], Player[playerid][malinki]);
                            mysql_query(ConnectMySQL, Qwery, false);
                    }
                /*case 4:
                {
                    if(Player[playerid][malinki] < 999)
                    {
                            SCM(playerid, COLOR_WHITE, "�� ����� ����� ������������ �������.");
                    }
                    else
                    {
                        SCM(playerid, 0x3377CCFF, "�� ��������� ���� ������� �� 999 ���.");
                        SetPlayerSkin(playerid, 115);

                        new Qwery[144];
                        format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `Skin` = '123' WHERE `id` = '%d'", Player[playerid][ID]);
                        mysql_query(ConnectMySQL, Qwery, false);

                        SetPlayerSkin(playerid, 123);

                        GivePlayerMoney(playerid, -999);
                        Player[playerid][malinki] -= 999;
                        Player[playerid][pSex] = 3;
                        Player[playerid][pSkin] = 123;

                        new Qwery1[144];
                        format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][ID], Player[playerid][malinki]);
                        mysql_query(ConnectMySQL, Qwery1, false);

                        new Qwery2[144];
                        format(Qwery2, sizeof(Qwery2), "UPDATE `Accounts` SET `Sex` = '3' WHERE `id` = '%d'", Player[playerid][ID]);
                        mysql_query(ConnectMySQL, Qwery2, false);
                    }*/
                }
            }
        }
        case 3873:
        {
                if (!response) return 1;

                switch(listitem)
                {
                        case 0:
                        {
                            PlayAudioStreamForPlayer(playerid, "http://malinovkadm.fun/sound/music/ya_budu.mp3");
                            SCM(playerid, 0xFFFFFFFF, "��� ���������� ������ �����������: /musicoff");
                        }
                        case 1:
                        {
                            PlayAudioStreamForPlayer(playerid, "http://malinovkadm.fun/sound/music/kus.mp3");
                            SCM(playerid, 0xFFFFFFFF, "��� ���������� ������ �����������: /musicoff");
                        }
                        case 2:
                        {
                            PlayAudioStreamForPlayer(playerid, "http://malinovkadm.fun/sound/music/punk.mp3");
                            SCM(playerid, 0xFFFFFFFF, "��� ���������� ������ �����������: /musicoff");
                        }
                        case 3:
                        {
                            PlayAudioStreamForPlayer(playerid, "http://malinovkadm.fun/sound/music/spokoistvie.mp3");
                            SCM(playerid, 0xFFFFFFFF, "��� ���������� ������ �����������: /musicoff");
                        }
                }
        }
        case 4241:
        {
            if(!response) return 1;
            SetPlayerPos(playerid, tpmp[0], tpmp[1], tpmp[2]);
            SCM(playerid, 0x5cff7aFF, "�� ����������������� �� �����������, � ��� �������������� ������� ������");
            ResetPlayerWeapons(playerid);
            SetPVarInt(playerid, "TPMP", 1);
            SetPlayerVirtualWorld(playerid, 555);
        }
        case 4386:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: SetPlayerPos(playerid, 2140.6221,-1979.1801,188.2424);
                    case 1: SetPlayerPos(playerid, 1475.8309,1680.0964,531.9307);
                }
            }
        }
        case 37:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0:
                    {
                        new comanda[10];
                        if(Player[playerid][pSex] == 1) comanda = "������";
                        if(Player[playerid][pSex] == 2) comanda = "��������";
                        if(Player[playerid][pSex] == 4) comanda = "��������";
                        format(string,sizeof string,"{FFFFFF}�������: \t\t\t{0089ff}%s\n{FFFFFF}����� ��������: \t\t{0089ff}#%d\n{FFFFFF}�������: \t\t\t{0089ff}%s\n\n{FFFFFF}_________________________________________\n\n����� �������:\t\t\t{0089ff}%d",gpname(playerid), Player[playerid][ID], comanda, Player[playerid][pLevel]);
                        ShowPlayerDialog(playerid,123,DIALOG_STYLE_MSGBOX,"{EE3366}����������",string,"�������","");
                    }
                    case 1: SPD(playerid, 9822, DSM, "{EE3366}����� �������","{FFFFFF}�������� ������ ��� ������� �� ���� ������ ����.\n\n��������: ���� �� ������� ESC �� �������������� ������� ���������","������","��������");
                    case 2: SPD(playerid, 9825, DSI, "{EE3366}��������� ������", "{FFFFFF}��� ��������� ������, ������� ��� � ���� ����.\n\n������ �� ������ �������� �����, ���� �� �������� �����������.\n��� ������ ���������� ���������� � ��� ���������.","��������","������");
                    case 3: SPD(playerid, 9823, DSL, "{EE3366}������� �������", "{FFFFFF}/mn - ���� ������\n/loc - �������� �������\n/r - ����� ��� �������\n/try - ��������� ���������� ����������\n/report - ����� � �������� ���������\n/shop - ������� �������\n/audiomsg - ��������/��������� ����� ���������\n/id - �� ������\n/sms - ��������� ������ ��������� ������\n\
					/duel - ������� ������ �� �����", "�����", "�������");
                    case 4:
                    {
                        SetPlayerPos(playerid, 2381.6975,-1906.1652,22.6751);
                        SetPlayerFacingAngle(playerid, 178.6008);
                        SCM(playerid, -1, "�� ������� � ������� - ������, ��� ������ �� �������� ���������� �����������: /kq");
                        SetPlayerVirtualWorld(playerid, 222);
                        return true;
                    }
                }
            }
        }
        case 9823:
        {
        }
        case 9828:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: SPD(playerid, 9823, DSL, "{EE3366}������� �������� �������", "{FFFFFF}1. /tp - ������� ��������\n2. /as - ��������� �������� �������\n3. /ans - �������� ������\n4. /a - �����-���\n5. /g - ����������������� � ������\n6. /slap - ��������� ������\n7. /stats - ���������� ������\n8. /spawn - ������� ������\n9. /fly - ����� �����", "�����", "�������");
                    case 1: SPD(playerid, 9823, DSL, "{EE3366}������� �������� �������", "{FFFFFF}1. /pay - �������� ������� ������\n2. /gethere - ���������������� � ���� ������\n3. /kick - ������� ������\n4. /mute - �������� ������\n5. /unmute - ��������� ������\n6. /vmute - ������������� ��������� ��� ������\n7. /unvmute - �������������� ��������� ��� ������\n8. /weather - ���������� ������\n9. /dveh - ������� ���������", "�����", "�������");
                    case 2: SPD(playerid, 9823, DSL, "{EE3366}������� �������� �������", "{FFFFFF}1. /unban - �������������� ������� ������", "�����", "�������");
                    case 3: SPD(playerid, 9823, DSL, "{EE3366}������� �������� �������", "{FFFFFF}1. /msg - ��������� �������\n2. /ban - ������������� ������� ������\n3. /offban - ������������� ������ � ��������\n4. /prison - ������� ������ ���������", "�����", "�������");
                    case 4: SPD(playerid, 9823, DSL, "{EE3366}������� �������� �������", "{FFFFFF}1. /setmp - ������� ����� �����������\n2. /mphp - ������ HP ������� � �������\n3. /mpgivegun - ������ ������ ������� � �������\n4. /veh - ������� ���������", "�����", "�������");
                    case 5: SPD(playerid, 9823, DSL, "{EE3366}������� �������� �������", "{FFFFFF}1. /makeadmin - �������� ������� �������� �������\n2. /serials - GPCI ID � ����\n3. /tempskin - ������ ��������� ����\n4. /payday - ������� payday �� �������\n5. /alladmins - ����� ������ ������� ��������\n6. /statsadmin - ���������� �������� �������\n7. /offadmin - ����� �������� ������� �������", "�����", "�������");
                }
            }
        }
        case 9827:
        {
            if(response)
            {
                    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");

					if(strlen(inputtext) == 0) return SCM(playerid, COLOR_GREY, "������� ������ ��������� ��� ������� 1 ������");

                    new string1[144];
                    format(string1, sizeof(string1), "[%s #%d] %s[%d] ��������� ���� ��������� ������� (%s)", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid, (inputtext));
                    SendAdminMessage(COLOR_ADMINCHAT, string1);

                    new string_auto[144];
                    format(string_auto,sizeof(string_auto),"~w~��������� �������,~n~~b~%s", (inputtext));
                    GameTextForPlayer(playerid, string_auto, 5000, 1);
                    
                    SetPlayerName(playerid, (inputtext));
            }
            else
            {
            }
        }
        case 3211:
        {
            if(response)
            {
                    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
                    if(!strlen(inputtext) || strlen(inputtext) < 5) return SCM(playerid, COLOR_WHITE, "������� ������ ��������� ��� ������� 5 ��������");

                    new name[64],
                    text[128];
                    GetPVarString(playerid, "NewNickName", name, sizeof(name));
                    format(text, sizeof(text), "SELECT * FROM `Accounts` WHERE `name` = '%s'", (inputtext));
                    mysql_query(ConnectMySQL, text, false);

                    SetPlayerName(playerid, (inputtext));
                    Player[playerid][pName] = gpname(playerid);

                    new string_auto[144];
                    format(string_auto,sizeof(string_auto),"~w~����� �������,~n~~b~%s", (inputtext));
                    GameTextForPlayer(playerid, string_auto, 5000, 1);

                    new Qwery[144];
                    format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `name` = '%s' WHERE `id` = '%d'",(inputtext), Player[playerid][ID]);
                    mysql_query(ConnectMySQL, Qwery, false);
            }
            else
            {
            }
        }
        case 7213:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0:
                    {
                        if(Player[playerid][HideMe] == 0)
                        {
                            SetTimerEx("adialogtime", 50, 0, "d", playerid);
                            Player[playerid][HideMe] = 1;
                            for(new i = 0; i < MAX_PLAYERS; i++)
                            {
                                ShowPlayerNameTagForPlayer(i,playerid, false);
                                SetPlayerHealth(playerid, 9999.0);
                            }
                        }
                        else
                        {
                            SetTimerEx("adialogtime", 50, 0, "d", playerid);
                            Player[playerid][HideMe] = 0;
                            for(new i = 0; i < MAX_PLAYERS; i++)
                            {
                                ShowPlayerNameTagForPlayer(i,playerid, true);
                                SetPlayerHealth(playerid, 100.0);
                            }
                        }
                    }
                    case 1:
                    {
                        SPD(playerid, 9827, DSI, "{EE3366}��������� �������� �� ���������", "{FFFFFF}��� ��������� �������� �� ��������� (��� ����� ������)\n������� ��� � ���� ����.","��������","������");
                    }
                }
            }
        }
        case 9825:
        {
            if(response)
            {
                if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
                SCM(playerid, COLOR_BLUE, "�� ������� �������� ���� ������");

                new Qwery[144];
                format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `password` = '%s' WHERE `id` = '%d'",(inputtext), Player[playerid][ID]);
                mysql_query(ConnectMySQL, Qwery, false);
            }
            else
            {
            }
        }
        case 9822:
        {
            if(response)
            {
                Player[playerid][pSex] = 1;
                Player[playerid][pSkin] = 114;
            }
            else
            {
                Player[playerid][pSex] = 2;
                Player[playerid][pSkin] = 28;
            }
            Player[playerid][pLevel] = 1;
            SCM(playerid, COLOR_WHITE, "�� ������� �������� ���� �������");
            SpawnPlayer(playerid);
            SetPlayerVirtualWorld(playerid, 0);
            TogglePlayerSpectating(playerid,0);
            //SpawnPlayer(playerid);
        }
        case 4385:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: SetWeather(10);
                    case 1: SetWeather(11);
                    case 2: SetWeather(8);
                    case 3: SetWeather(9);
                    case 4: SetWeather(14);
                    case 5: SetWeather(19);
                    case 6: SetWeather(20);
                    case 7: SetWeather(23);
                    case 8: SetWeather(27);
                    case 9: SetWeather(30);
                    case 10: SetWeather(33);
                    case 11: SetWeather(-1337);
                }
            }
        }
        case 1:
        {
            if(response)
            {
                if(!strlen(inputtext))
                {
                    TogglePlayerSpectating(playerid, true);
                    SetPlayerVirtualWorld(playerid, playerid);
                    f("{FFFFFF}������ ������� �� ���������������, ������� ��� �������� ��� ����������� ������� ������ � ���� ����\n\n�������� �������� �� ��, ��� � ��������� ������� ������ ����������, ������ � ���� ����������");
                    SPD(playerid, 1, DIALOG_STYLE_PASSWORD, "{db2751}����������� ������������", string,"�����","�����");
                    return true;
                }
                for(new i = strlen(inputtext); i != 0; --i)
                switch(inputtext[i])
                {
                    case '�'..'�', '�'..'�': return SPD(playerid, 1, DSI, "������", "{FFFFFF}���, ������ ������ ���� �� ��������", "�����", "�����");
                }
                if(strlen(inputtext) < 6 || strlen(inputtext) > 20) return SPD(playerid, 1, DSI, "{db2751}������", "{FFFFFF}������ ������ ��������� �� ����� 6 � �� ����� 20 ��������.\n���������� ������� ������ ������.", "�����", "�����");
                strmid(Player[playerid][pPass], inputtext, 0, strlen(inputtext), 21);
                SPD(playerid, 2, DSM, "{EE3366}����� �������","{FFFFFF}������, ��� �� � ��������� �� ������ ����� ����������\n{FFFF33}�������� �������� �� ��, ��� ���� ����� ������ � �������� ��� ������","������","��������");
            }
            else
            {
                SCM(playerid, COLOR_GREY, "�� ���� ��������� �� �������. ��� ������ �������: /q");
                Kickk(playerid);
            }
        }
        case 2:
        {
            if(response)
            {
                Player[playerid][pSex] = 1;
                Player[playerid][pSkin] = 114;
            }
            else
            {
                Player[playerid][pSex] = 2;
                Player[playerid][pSkin] = 28;
            }

            mysql_format(ConnectMySQL, string, sizeof(string), "INSERT INTO `Accounts` (`Name`, `Level`, `Skin`, `Sex`, `Password`, `admin`) VALUES ('%s', '%d', '%d', '%d', '%s', '0')", GN(playerid), Player[playerid][pLevel], Player[playerid][pSkin], Player[playerid][pSex], Player[playerid][pPass]);
            mysql_function_query(ConnectMySQL, string, true, "Registr", "d", playerid);

			f("{FFFFFF}���� ������� ���� � ����� ���� ������, ������������� �� ���������������\n\n��� ����������� ������� ������ � ���� ����, ������ ������ ����������\n�������, �� ��, ��� �� � ���� <3");
			SPD(playerid, 3, DIALOG_STYLE_PASSWORD, "{db2751}�����������", string,"�����","�����");
            /*Login[playerid] = true;
            SCM(playerid, 0xd16b6b00, "���, �� ������� ������������������ �� �������.");
            SCM(playerid, 0xd16b6b00, "�� ���� ������������� ���������� �� DM ����.");
            
            
            SetPVarInt(playerid, "Logged", 1);
            
            new string_auto[144];
            format(string_auto,sizeof(string_auto),"~w~����� ����������,~n~~b~%s", gpname(playerid));
            GameTextForPlayer(playerid, string_auto, 5000, 1);
            
            Player[playerid][pLevel] = 1;
            Player[playerid][ADMIN] = 0;
            Player[playerid][Spectating] = -1;
            Player[playerid][MUTE] = 0;
            Player[playerid][BAN] = 0;
            Player[playerid][malplus] = 0;
            Player[playerid][malinki] = 0;
            
            SetPlayerHealth(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            TogglePlayerSpectating(playerid,0);
            //SpawnPlayer(playerid);*/
        }
        case 3:
        {
            if(response)
            {
                if(!strlen(inputtext))
                {
                    TogglePlayerSpectating(playerid, true);

                    SetPlayerVirtualWorld(playerid, playerid);
                    f("{FFFFFF}���� ������� ���� � ����� ���� ������, ������������� �� ���������������\n\n��� ����������� ������� ������ � ���� ����, ������ ������ ����������\n�������, �� ��, ��� �� � ���� <3");
                    SPD(playerid, 3, DIALOG_STYLE_PASSWORD, "{db2751}�����������", string,"�����","�����");
                    return true;
                }
                
                mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `name` = '%e' AND `password` = '%e'", GN(playerid), inputtext);
                return mysql_tquery(ConnectMySQL, string, "OnLogin", "d", playerid);
            }
            else
            {
                SCM(playerid, COLOR_GREY, "�� ���� ��������� �� �������. ��� ������ �������: /q");
                Kickk(playerid);
            }
        }
    }
        return true;
}
public OnPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid, Player[playerid][pSkin]);
    if(Player[playerid][pSex] == 1)
    {
        SetPlayerColor(playerid, 0x66CCFFFF);
    }

    if(Player[playerid][pSex] == 2)
    {
        SetPlayerColor(playerid, 0x663399FF);
    }

    if(Player[playerid][malplus] == 0)
    {
        SetPlayerHealth(playerid, 100);
    }
    else
    {
        SetPlayerHealth(playerid, 160);
    }

    SetPlayerSpawn(playerid);
    //SpawnPlayer(playerid);
    switch(random(5))
    {
            case 0: SetPlayerPos(playerid, 1489.9600,-1280.2625,14.1614);
            case 1: SetPlayerPos(playerid, 1510.3495,-1254.2402,13.8423);
            case 2: SetPlayerPos(playerid, 1523.2744,-1240.5864,14.1840);
            case 3: SetPlayerPos(playerid, 1473.4999,-1230.5640,11.6712);
            case 4: SetPlayerPos(playerid, 1476.8962,-1186.9644,12.5799);
            case 5: SetPlayerPos(playerid, 1496.6620,-1198.9233,13.0115);
    }
    SetPlayerInterior(playerid, 0);
    TogglePlayerSpectating(playerid, false);
    GivePlayerWeapon(playerid, 24, 10000);
    SetPlayerVirtualWorld(playerid, locvw[playerid]);
    
    TextDrawShowForPlayer(playerid, mdm_logo_TD);
    
	if(GetPVarInt(playerid, "DuelStart") != 0)
	{
		SetPlayerVirtualWorld(GetPVarInt(playerid, "DuelRival"), playerid+200);
		SetPlayerVirtualWorld(playerid, playerid+200);

		SetPlayerPos(GetPVarInt(playerid, "DuelRival"), 1489.0593,-1263.4598,13.2997);
		SetPlayerPos(playerid, 1488.5297,-1219.5250,12.1295);
		
		SetPlayerFacingAngle(GetPVarInt(playerid, "DuelRival"), 358.3782);
		SetPlayerFacingAngle(playerid, 177.7348);
	}
    return true;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
    if(areaid == zonals)
    {
  //SetPlayerPos(playerid,1481.5237,-1261.9025,12.9341);
    }
    return true;
}

stock GivePlayerHealth(playerid,Float:health)
{
    new Float:hp;
    GetPlayerHealth(playerid,hp);
    SetPlayerHealth(playerid,hp+health);
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
        new Float:oldposx, Float:oldposy, Float:oldposz;
        GetPlayerPos(damagedid, oldposx, oldposy, oldposz);
        if(IsPlayerInRangeOfPoint(playerid, 52.0, oldposx, oldposy, oldposz))
        {
                if(playerid != INVALID_PLAYER_ID)
                {
                        if(PlayerToPoint(50, playerid, 2381.6975,-1906.1652,22.6751))
                        {
                                    SetPlayerHealth(damagedid, 100);
                                    SCM(playerid, COLOR_GREY, "���� ������������: �� ���������� � ������");
                                    return true;
                        }
                        if(Player[damagedid][HideMe] == 1)
                        {
                                    SetPlayerHealth(damagedid, 100);
                                    SCM(playerid, COLOR_GREY, "���� ������������: ����� �������� ������� ��������");
                                    return true;
                        }
                        switch(weaponid)
                        {
                                case 0: GivePlayerHealth(damagedid, -4);
                                case 1: GivePlayerHealth(damagedid, -6);
                                case 2: GivePlayerHealth(damagedid, -7);
                                case 3: GivePlayerHealth(damagedid, -10);
                                case 4..8: GivePlayerHealth(damagedid, -13.4);
                                case 9: GivePlayerHealth(damagedid, -19.8);
                                case 10..13: GivePlayerHealth(damagedid, -30);
                                case 14: GivePlayerHealth(damagedid, -18);
                                case 15: GivePlayerHealth(damagedid, -20);
                                case 16: GivePlayerHealth(damagedid, -30);
                                case 17: GivePlayerHealth(damagedid, -3);
                                case 18: GivePlayerHealth(damagedid, -13);
                                case 19: GivePlayerHealth(damagedid, -3);
                                case 20: GivePlayerHealth(damagedid, -3);
                                case 21: GivePlayerHealth(damagedid, -3);
                                case 22: GivePlayerHealth(damagedid, -8.6);
                                case 23: GivePlayerHealth(damagedid, -9.7);
                                case 24:
                                {
                                    GivePlayerHealth(damagedid, -47.8);
                                    PlayAudioStreamForPlayer(playerid, "http://malinovkadm.fun/sound/damage.mp3");
                                }
                                case 25: GivePlayerHealth(damagedid, -25.3);
                                case 26: GivePlayerHealth(damagedid, -30.3);
                                case 27: GivePlayerHealth(damagedid, -22.4);
                                case 28: GivePlayerHealth(damagedid, -8);
                                case 29: GivePlayerHealth(damagedid, -9);
                                case 30: GivePlayerHealth(damagedid, -8);
                                case 31: GivePlayerHealth(damagedid, -8);
                                case 32: GivePlayerHealth(damagedid, -7);
                                case 33: GivePlayerHealth(damagedid, -24);
                                case 34: GivePlayerHealth(damagedid, -1);
                        }
                }
        }
        return 1;
}

forward PayDay();
public PayDay()
{
        for(new i=0; i<MAX_PLAYERS; i++)
        {
                new hour, minute, second;
                gettime(hour, minute, second);

                Player[i][malinki] += 25;
                GivePlayerMoney(i, 25);

                new banktext[144];
                new strt[144];
                new zptext[144];
                format(strt,sizeof(strt),"���������� ����� {3377CC}%02d:%02d", hour, minute);
                SendClientMessage(i,-1,strt);
                SendClientMessage(i,0xFFFFFF00,"����� Malinovka DM (MDM):");
                SendClientMessage(i,0xFFFFFFFF," ____________________________");
                format(zptext,sizeof(zptext),"  �������� �������: {EE3366}25 ���.");
                SendClientMessage(i,-1,zptext);
                format(banktext,sizeof(banktext),"  ������� ������: {EE3366}%d �������.",Player[i][malinki]);
                SendClientMessage(i,-1,banktext);
                SendClientMessage(i,0xFFFFFFFF," ____________________________");
                
                switch(random(4))
                {
                    case 0: SetWeather(4);
                    case 1: SetWeather(8);
                    case 2: SetWeather(14);
                    case 3: SetWeather(9);
                }
        
                new string_auto[144];
                format(string_auto,sizeof(string_auto),"~b~PayDay");
                GameTextForPlayer(i, string_auto, 5000, 1);
                
                PlayAudioStreamForPlayer(i, "http://malinovkadm.fun/sound/payday.mp3");

                ResetPlayerMoney(i);
                GivePlayerMoney(i, Player[i][malinki]);
                MysqlUpdatePlayerInt(i, "malinki", Player[i][malinki]);
        }
        return 1;
}

forward Restart();
public Restart()
{
    for(new i=0; i<MAX_PLAYERS; i++)
    {
        SendClientMessage(i, COLOR_TOMATO, " ");
        SendClientMessage(i, COLOR_TOMATO, " ");
        SendClientMessage(i, COLOR_TOMATO, "���������� ������� �������, ���������� ���������...");
        SendClientMessage(i, COLOR_TOMATO, " ");
        SendClientMessage(i, COLOR_TOMATO, " ");

        Kick(i);
        TogglePlayerSpectating(i, true);
        GameModeExit();
    }
    return 1;
}

/*forward checkonline(playerid);
public checkonline(playerid)
{
	new string[144];
	mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `online` = '1'");
 	return mysql_tquery(ConnectMySQL, string, "LoadCheckOnline", "d", playerid);
}*/

forward UpdateTime();
public UpdateTime()
{
        new hour, minute, second;
        gettime(hour, minute, second);
        if(minute == 0 && second == 0)
        {
            PayDay();
           	for(new i=0; i<MAX_PLAYERS; i++)
            {
            	if(Player[i][online] >= 60)
            	{
            	    if(Player[i][malplus] == 1) return SCM(i, 0x00bfffFF, "������� �� ���������� ���� ������, �� � ��� ��� ���� �+. ����� ����������� �����");
					SCM(i, 0x00bfffFF, "�� �������� ��������� + �� ���������� ������, �����������! ��� �� ��������� ����.");
					Player[i][malplus] = 1;
					MysqlUpdatePlayerInt(i, "malplus", Player[i][malplus]);
            	}
            	if(Player[i][online] >= 120)
            	{
					SCM(i, 0x00bfffFF, "�� �������� 100 ������� �� ���������� ������, �����������! ��� �� ��������� ����.");
					Player[i][malinki] += 100;
					SetPlayerMoney(i, Player[i][malinki]);
					MysqlUpdatePlayerInt(i, "malinki", Player[i][malinki]);
            	}
            	if(Player[i][online] >= 180)
            	{
            		if(Player[i][pSkin] == 123) return SCM(i, 0x00bfffFF, "������� �� ���������� ���� ������, �� � ��� ��� ���� ���� ��� �������. �������� ����!");
					SCM(i, 0x00bfffFF, "�� �������� ���� '��� ������' �� ���������� ������, �����������!");
					Player[i][pSkin] = 123;
					Player[i][pSex] = 3;
					SetPlayerSkin(i, 123);
					MysqlUpdatePlayerInt(i, "Skin", Player[i][pSkin]);
					MysqlUpdatePlayerInt(i, "Sex", Player[i][pSex]);
            	}
			}
        }
        if(hour == 7 && minute == 9 && second == 0)
        {
            for(new i=0; i<MAX_PLAYERS; i++)
            {
                SendClientMessage(i, COLOR_TOMATO, " ");
                SendClientMessage(i, COLOR_TOMATO, " ");
                SendClientMessage(i, COLOR_TOMATO, "[!!!] �������� ����� ������ ���������� �������������� ������������ �������!");
                SendClientMessage(i, COLOR_TOMATO, " ");
                SendClientMessage(i, COLOR_TOMATO, " ");
            }
        }
        if(minute == 30 && second == 0)
        {
            SendClientMessageToAll(0xf00e5dFF,"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            SendClientMessageToAll(0xf00e5dFF,"{FFFFFF}� ��� ���� ���� ���� � �����, ��� �������� �� ������ -{f00e5d}https://malinovkadm.fun");
            SendClientMessageToAll(0xf00e5dFF,"{FFFFFF}� ����� ���� ���� ���� ������ � ��. ������ ������� ������ ��� - {f00e5d}https://vk.com/malinovkadm");
            SendClientMessageToAll(0xf00e5dFF,"{FFFFFF}��������� �� ����� discord ������� - {f00e5d}https://malinovkadm.fun/discord/");
            SendClientMessageToAll(0xf00e5dFF,"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        }
        if(hour == 7 && minute == 10 && second == 0)
        {
       		for(new i=0; i<MAX_PLAYERS; i++)
			{
                SendClientMessage(i, COLOR_TOMATO, " ");
                SendClientMessage(i, COLOR_TOMATO, " ");
                SendClientMessage(i, COLOR_TOMATO, "���������� �������������� ������������ �������");
                SendClientMessage(i, COLOR_TOMATO, " ");
                SendClientMessage(i, COLOR_TOMATO, " ");
				Kick(i);
			}
   			SetTimer("Restart", 1000, 0);
        }
        if(hour == 0 && minute == 0 && second == 0)
        {
       		for(new i=0; i<MAX_PLAYERS; i++)
			{
				Player[i][online] = 0;
				Player[i][REPORTS] = 0;
			}
		    new Query[128];
		    format(Query, sizeof(Query), "UPDATE `Accounts` SET reports = '0' WHERE reports != '0'");
		    mysql_tquery(ConnectMySQL, Query, "", "");
		    
		    new Query2[128];
		    format(Query2, sizeof(Query2), "UPDATE `Accounts` SET online = '0' WHERE online != '0'");
		    mysql_tquery(ConnectMySQL, Query2, "", "");
        }
        return true;
}

forward OnlinePlus(playerid);
public OnlinePlus(playerid)
{
	Player[playerid][online] += 1;

 	new Query[128];
    format(Query, sizeof(Query), "UPDATE `Accounts` SET online = '%d' WHERE `id` = '%d' LIMIT 1", Player[playerid][online], Player[playerid][ID]);
 	return mysql_tquery(ConnectMySQL, Query, "", "");
}

public OnGameModeInit()
{
    SvInit(SV_UINT:40000);

    new hour, minute, second;
    gettime(hour, minute, second);
    SetWorldTime(hour);

    switch(random(4))
    {
        case 0: SetWeather(4);
        case 1: SetWeather(8);
        case 2: SetWeather(14);
        case 3: SetWeather(9);
    }

    SetTimer("UpdateTime", 1000, 1); // ������ PayDay
    SetTimer("checkadminnick", 100, 1);
    
    SendRconCommand("hostname "HOSTNAME"");
    SetGameModeText(GAMEMODE);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    LimitPlayerMarkerRadius(30.0);
    ConnectMySQL = mysql_connect(MySQL_HOST, MySQL_USER, MySQL_BD, MySQL_PASS);
    mysql_function_query(ConnectMySQL, "SET NAMES utf8", false, "", "");
    //mysql_tquery(ConnectMySQL, "SET NAMES utf8", "", "");
    if(mysql_errno()==0) printf("����������� � �� ������ �������!");
    else printf("������������ � �� �� �������");
    SetTimer("SecondUpdate", 1000, true);
    SetTimer("CheckVoiceMutePlayer", 1000, true);

    CaptZone = GangZoneCreate(1449.5, -1355, 1591.5, -1133);

    SetTimer("CheckPlayerHideMe", 1000, 1);

    mdm_logo_TD = TextDrawCreate(547.9868, 3.9165, "mdl20201:default");
    TextDrawTextSize(mdm_logo_TD, 87.0000, 30.0000);
    TextDrawAlignment(mdm_logo_TD, 1);
    TextDrawColor(mdm_logo_TD, -1);
    TextDrawBackgroundColor(mdm_logo_TD, 255);
    TextDrawFont(mdm_logo_TD, 4);
    TextDrawSetProportional(mdm_logo_TD, 0);
    TextDrawSetShadow(mdm_logo_TD, 0);

    // ������� ���� �����
    new tmpobjid;
    tmpobjid = CreateObject(19313, 1458.224853, -1237.477905, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1223.498657, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1209.779052, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1195.837768, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1181.816772, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1465.244873, -1174.834716, 13.770874, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1479.234741, -1174.834716, 13.770874, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1493.253784, -1174.834716, 13.770874, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1507.204711, -1174.834716, 14.630882, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1521.324951, -1174.834716, 14.630882, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1535.355712, -1174.834716, 14.630882, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1549.406005, -1174.834716, 14.630882, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1563.434326, -1174.834716, 14.630882, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1181.855224, 14.630882, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1195.865356, 14.630882, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1209.906372, 14.630882, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1223.814575, 14.630882, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1237.733764, 14.630882, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1567.048461, -1250.850952, 14.630882, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1560.265014, -1263.039550, 14.630882, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1553.470092, -1275.246337, 14.630882, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1546.656860, -1287.487548, 14.630882, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1539.836303, -1299.742675, 14.630882, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1530.294311, -1302.512308, 14.630882, 0.000000, 0.000000, -29.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1518.061645, -1295.701293, 14.630882, 0.000000, 0.000000, -29.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1505.014038, -1292.368286, 14.730893, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1490.994873, -1292.368286, 14.730893, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1477.024291, -1292.368286, 14.730893, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1463.032836, -1292.368286, 14.730893, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1453.812255, -1292.368286, 14.730893, 0.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1251.467163, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1265.448486, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1279.429687, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1458.224853, -1293.390625, 13.770874, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1223.814575, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1216.233642, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1208.083740, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1198.193725, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1190.463134, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1181.482910, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1173.872680, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1234.504638, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1245.114624, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1255.614746, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1265.533935, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1570.414794, -1265.533935, 21.410837, 0.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1567.048461, -1250.850952, 18.600885, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1560.512207, -1262.593505, 18.600885, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1555.526611, -1271.549438, 18.600885, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1551.129638, -1279.448486, 18.600885, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    tmpobjid = CreateObject(19313, 1543.489379, -1293.175903, 18.600885, 0.000000, 0.000000, -119.099975, 300.00);
    SetObjectMaterial(tmpobjid, 0, 1875, "podval", "alpha_hide", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 1875, "podval", "alpha_hide", 0x00000000);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    tmpobjid = CreateObject(9161, 1501.895263, -1206.759765, 13.614306, 1.500000, -2.999999, 0.000000, 300.00);
    tmpobjid = CreateObject(9161, 1485.172241, -1193.939819, 13.320672, 1.799998, -1.399999, 360.000000, 300.00);
    tmpobjid = CreateObject(10171, 1508.108520, -1201.520385, 13.634518, -3.899991, -1.600000, 129.000000, 300.00);
    tmpobjid = CreateObject(9212, 1518.531372, -1221.732299, 13.193823, 0.000000, -2.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(1685, 1496.724731, -1212.363891, 12.290484, 0.699998, -2.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(825, 1487.901123, -1206.678100, 10.558279, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(1685, 1488.770141, -1222.161010, 11.892965, 0.699998, -2.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(1685, 1486.554199, -1221.898437, 11.755645, 0.699998, -2.000000, -23.099992, 300.00);
    tmpobjid = CreateObject(4994, 1473.987426, -1236.036376, 11.490892, -1.299998, -1.399999, 3.599997, 300.00);
    tmpobjid = CreateObject(10146, 1469.947387, -1201.649780, 11.531841, 0.000000, 0.000000, -175.799850, 300.00);
    tmpobjid = CreateObject(825, 1478.741088, -1236.230224, 10.788286, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(849, 1473.868164, -1234.356933, 10.863612, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(831, 1505.633789, -1235.016235, 12.561141, 0.000000, 0.000000, 117.199989, 300.00);
    tmpobjid = CreateObject(849, 1479.490112, -1197.810668, 11.558575, 0.000000, 6.399997, 270.000000, 300.00);
    tmpobjid = CreateObject(853, 1472.150512, -1200.119018, 11.357135, 0.000000, 0.000000, 266.600006, 300.00);
    tmpobjid = CreateObject(636, 1507.906738, -1235.053222, 12.171703, 0.000000, 0.000000, 90.000000, 300.00);
    tmpobjid = CreateObject(10146, 1520.427978, -1238.500854, 13.551772, 3.899996, 0.000000, -85.799850, 300.00);
    tmpobjid = CreateObject(10146, 1524.067626, -1237.813842, 14.156852, 8.999995, 0.000000, 89.100173, 300.00);
    tmpobjid = CreateObject(9161, 1502.214477, -1259.657592, 14.335494, 2.899996, -2.099997, 990.000000, 300.00);
    tmpobjid = CreateObject(9161, 1480.753051, -1273.773681, 14.244938, 2.899996, 2.100003, 1260.000000, 300.00);
    tmpobjid = CreateObject(9212, 1479.809570, -1252.022705, 11.991725, 0.000000, -2.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(9212, 1511.714233, -1267.035400, 13.866333, 0.000000, -1.399999, 0.000000, 300.00);
    tmpobjid = CreateObject(10171, 1509.615844, -1251.769531, 13.833463, -0.399993, 0.699998, 94.700019, 300.00);
    tmpobjid = CreateObject(1685, 1502.229248, -1248.555786, 12.971162, -2.599997, -2.000000, 9.500000, 300.00);
    tmpobjid = CreateObject(825, 1497.732910, -1251.729858, 11.908291, 0.000000, 0.000000, 31.499998, 300.00);
    tmpobjid = CreateObject(849, 1485.771362, -1265.064086, 12.478454, 0.000000, -2.800003, -155.799987, 300.00);
    tmpobjid = CreateObject(634, 1481.236328, -1217.101318, 10.916381, 0.000000, 0.000000, 75.699996, 300.00);
    tmpobjid = CreateObject(635, 1477.786132, -1264.914428, 11.908736, 0.000000, 0.000000, 26.300008, 300.00);
    tmpobjid = CreateObject(4894, 1539.766235, -1211.254150, 10.884531, 0.000000, 0.000000, 80.300003, 300.00);
    tmpobjid = CreateObject(4894, 1547.701416, -1207.558715, 10.884531, 0.000000, 0.000000, 80.300003, 300.00);
    tmpobjid = CreateObject(4894, 1530.412963, -1295.523437, 9.394517, 0.000000, 0.000000, 80.300003, 300.00);
    tmpobjid = CreateObject(4894, 1497.044799, -1293.038208, 9.394517, 0.000000, 0.000000, 179.300003, 300.00);
    tmpobjid = CreateObject(4894, 1496.924316, -1302.907714, 10.964517, 0.000000, 0.000000, 179.300003, 300.00);
    tmpobjid = CreateObject(4894, 1500.151245, -1313.888671, 10.964517, 0.000000, 0.000000, 179.300003, 300.00);
    tmpobjid = CreateObject(4894, 1501.879638, -1172.309570, 8.604511, 0.000000, 0.000000, 179.300003, 300.00);
    tmpobjid = CreateObject(4894, 1502.004638, -1162.069946, 8.604511, 0.000000, 0.000000, 179.300003, 300.00);
    tmpobjid = CreateObject(4894, 1500.084106, -1147.345336, 8.604511, 0.000000, 0.000000, 179.300003, 300.00);
    tmpobjid = CreateObject(4894, 1565.402099, -1209.945312, 10.884531, 0.000000, 0.000000, 80.300003, 300.00);
    tmpobjid = CreateObject(636, 1455.424316, -1235.053222, 11.311697, 0.000000, 0.000000, 90.000000, 300.00);
    tmpobjid = CreateObject(634, 1449.770385, -1261.516479, 10.916381, 0.000000, 0.000000, 75.699996, 300.00);
    tmpobjid = CreateObject(634, 1459.479614, -1194.355102, 10.916381, 0.000000, 0.000000, 75.699996, 300.00);
    
    tmpobjid = CreateObject(18884, 1475.834228, 1680.171875, 628.421203, 0.000000, 0.000000, 0.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 2622, "M@RS_megashop", "roof_uj1", 0x00000000);
    tmpobjid = CreateObject(18884, 1475.834228, 1680.171875, 832.781066, 180.000000, 0.000000, 0.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 2622, "M@RS_megashop", "roof_uj1", 0x00000000);
    tmpobjid = CreateObject(19071, 1474.391601, 1756.783203, 531.524047, 90.000000, 0.000000, 180.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 4028, "sevas_dom6", "dom6_ent4", 0x00000000);
    tmpobjid = CreateObject(19071, 1474.391601, 1585.502563, 531.524047, 90.000000, 0.000000, 360.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 4028, "sevas_dom6", "dom6_ent4", 0x00000000);
    tmpobjid = CreateObject(19071, 1379.930664, 1685.372558, 531.524047, 90.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 4028, "sevas_dom6", "dom6_ent4", 0x00000000);
    tmpobjid = CreateObject(19071, 1379.930664, 1685.372558, 531.524047, 90.000000, 0.000000, 270.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 4028, "sevas_dom6", "dom6_ent4", 0x00000000);
    tmpobjid = CreateObject(19071, 1555.531005, 1685.372558, 531.524047, 90.000000, 0.000000, 450.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 4028, "sevas_dom6", "dom6_ent4", 0x00000000);
    
    // �������� ������
    tmpobjid = CreateObject(10259, 2368.122802, -1916.425170, 21.839147, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 2, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    tmpobjid = CreateObject(10259, 2368.122802, -1915.504272, 21.839147, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 2, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    tmpobjid = CreateObject(10259, 2368.122802, -1914.585449, 21.839147, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 2, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    tmpobjid = CreateObject(10259, 2368.122802, -1913.654541, 21.839147, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 2, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    tmpobjid = CreateObject(10259, 2368.122802, -1913.665039, 21.839147, 0.000000, 0.000000, 90.000000, 300.00);
    SetObjectMaterial(tmpobjid, 0, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 1, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    SetObjectMaterial(tmpobjid, 2, 2440, "pochtamt_bob88", "ground1", 0x00000000);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    tmpobjid = CreateObject(1569, 2380.166015, -1904.185424, 21.675144, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(1569, 2383.048583, -1904.185424, 21.675144, 0.000000, 0.000000, 180.000000, 300.00);
    tmpobjid = CreateObject(10097, 2378.731689, -1910.578125, 22.415161, 0.000000, 0.000000, 270.000000, 300.00);
    tmpobjid = CreateObject(10097, 2378.731689, -1910.578125, 21.695144, 0.000000, 180.000000, 270.000000, 300.00);
    tmpobjid = CreateObject(10097, 2373.307861, -1910.578125, 21.695144, 0.000000, 180.000000, 270.000000, 300.00);
    tmpobjid = CreateObject(10097, 2373.280029, -1910.578125, 22.415161, 0.000000, 0.000000, 270.000000, 300.00);
    tmpobjid = CreateObject(10089, 2368.364501, -1914.460937, 24.795209, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(10089, 2368.364501, -1916.092529, 24.795209, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(10147, 2368.969238, -1916.421752, 22.338050, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(10147, 2369.419677, -1913.921508, 22.338050, 0.000000, 0.000000, 131.199996, 300.00);
    tmpobjid = CreateObject(10201, 2367.962890, -1915.091552, 22.855154, 0.000000, 0.000000, 90.000000, 300.00);
    tmpobjid = CreateObject(10199, 2377.321533, -1903.963989, 23.005149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(10199, 2363.410400, -1916.205688, 23.005149, 0.000000, 0.000000, 90.000000, 300.00);
    tmpobjid = CreateObject(10241, 2385.258789, -1904.866210, 22.435142, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(10243, 2383.342041, -1904.817749, 21.675144, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(10243, 2380.582031, -1904.817749, 21.675144, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(743, 2378.453613, -1904.884033, 21.915149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(679, 2378.433349, -1904.901611, 22.195156, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(743, 2373.892089, -1904.884033, 21.915149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(743, 2368.959472, -1904.884033, 21.915149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(743, 2364.569091, -1904.884033, 21.915149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(679, 2373.904296, -1904.901611, 22.195156, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(679, 2368.940429, -1904.901611, 22.195156, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(679, 2364.600341, -1904.901611, 22.195156, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(743, 2373.892089, -1916.325561, 21.915149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(679, 2373.904296, -1916.320800, 22.195156, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(743, 2377.473144, -1916.325561, 21.915149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(679, 2377.495605, -1916.320800, 22.195156, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(743, 2382.104492, -1916.325561, 21.915149, 0.000000, 0.000000, 0.000000, 300.00);
    tmpobjid = CreateObject(679, 2382.149169, -1916.320800, 22.195156, 0.000000, 0.000000, 0.000000, 300.00);
    return true;
}

public OnObjectMoved(objectid)
{
    return 1;
}

public OnGameModeExit()
{
    mysql_close(ConnectMySQL);
    return true;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetSpawnInfo(playerid,0,0,0,0,0,0,0,0,0,0,0,0);
    SpawnPlayer(playerid);
    return true;
}

public OnPlayerRequestSpawn(playerid) return false; //�������� ������ Spawn
public OnPlayerCommandText(playerid, cmdtext[])
{
    return true;
}

//==============================[Publics]=======================================

forward checkadminnick(playerid);
public checkadminnick(playerid)
{
    if(Player[playerid][HideMe] == 1)
    {
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            ShowPlayerNameTagForPlayer(i, playerid, false);
        }
    }
    else
    {
        return true;
    }
    return true;
}

forward RukiOff(playerid);
public RukiOff(playerid)
{
    ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,0,0,0,0,0,0);
    return true;
}

publics kick(playerid)
{
    Kick(playerid);
    return true;
}

publics PlayerRegition(playerid)
{
    new string[206];
    new rows;
    new rows2;
    cache_get_data(rows, rows2);
    TogglePlayerSpectating(playerid,1);
    if(rows)
    {
        f("{FFFFFF}���� ������� ���� � ����� ���� ������, ������������� �� ���������������\n\n��� ����������� ������� ������ � ���� ����, ������ ������ ����������\n�������, �� ��, ��� �� � ���� <3");
        SPD(playerid, 3, DIALOG_STYLE_PASSWORD, "{db2751}�����������", string,"�����","�����");
    }
    else
    {
        f("{FFFFFF}������ ������� �� ���������������, ������� ��� �������� ��� ����������� ������� ������ � ���� ����\n\n�������� �������� �� ��, ��� � ��������� ������� ������ ����������, ������ � ���� ����������");
        SPD(playerid, 1, DIALOG_STYLE_PASSWORD, "{db2751}����������� ������������", string,"�����","�����");
    }
    return true;
}

publics OnLogin(playerid)
{
    new string[200];
    new rows;
    new rows2;
    cache_get_data(rows, rows2);
    if(rows)
    {
        Player[playerid][ID] = cache_get_field_content_int(0, "id");
        cache_get_field_content(0, "password", Player[playerid][pPass], ConnectMySQL, 21);
        Player[playerid][ADMIN] = cache_get_field_content_int(0, "admin");
        Player[playerid][REPORTS] = cache_get_field_content_int(0, "reports");
        
		Player[playerid][LASTDAY] = cache_get_field_content_int(0, "lastday");
		Player[playerid][LASTMOUNTH] = cache_get_field_content_int(0, "lastmounth");
		Player[playerid][LASTYEAR] = cache_get_field_content_int(0, "lastyear");
        
        Player[playerid][MUTE] = cache_get_field_content_int(0, "mute");
        Player[playerid][VMUTE] = cache_get_field_content_int(0, "vmute");
        Player[playerid][BAN] = cache_get_field_content_int(0, "ban");
        Player[playerid][pLevel] = cache_get_field_content_int(0, "Level");
        Player[playerid][pSkin] = cache_get_field_content_int(0, "Skin");
        Player[playerid][pSex] = cache_get_field_content_int(0, "Sex");
        Player[playerid][malinki] = cache_get_field_content_int(0, "malinki");
        Player[playerid][malplus] = cache_get_field_content_int(0, "malplus");
		Player[playerid][online] = cache_get_field_content_int(0, "online");
        
        SetPlayerScore(playerid, Player[playerid][pLevel]);
        
        onlinetimer[playerid] = SetTimerEx("OnlinePlus", 1000*60, true, "d", playerid);
        
        Login[playerid] = true;
        
        if(Player[playerid][BAN] == 1)
        {
            SCM(playerid, COLOR_GREY, "��� ������� ������������ ����� �� �� ������ ���������� �� �������...");
            Kick(playerid);
        }

        SetPlayerHealth(playerid, 0);
        SCM(playerid, 0xd16b6b00, "�� ������� ��������������, �������� ���� <3");
        SCM(playerid, 0xdb2751FF, "��������� ����� � ���� � ��������� �������! {FFFF99}(/gift)");
        
        if(Player[playerid][pSkin] == 20001) Player[playerid][pSkin] = 114;
        if(Player[playerid][pSkin] == 20002) Player[playerid][pSkin] = 28;
        if(Player[playerid][pSkin] == 20007) Player[playerid][pSkin] = 120;
        if(Player[playerid][pSkin] == 20008) Player[playerid][pSkin] = 115;
        if(Player[playerid][pSkin] == 20017) Player[playerid][pSkin] = 287;
        if(Player[playerid][pSkin] == 20020) Player[playerid][pSkin] = 123;
        
        if(Player[playerid][pSex] == 1)
        {
            SetPlayerColor(playerid, 0x66CCFFFF);
        }
        if(Player[playerid][pSex] == 2)
        {
            SetPlayerColor(playerid, 0x663399FF);
        }
        if(Player[playerid][pSex] == 3)
        {
            SetPlayerColor(playerid, 0x339933FF);
        }

        new string_auto[144];
        format(string_auto,sizeof(string_auto),"~w~� ������������,~n~~b~%s", gpname(playerid));
        GameTextForPlayer(playerid, string_auto, 5000, 1);
        
        SetPVarInt(playerid, "Logged", 1);
        SetPlayerVirtualWorld(playerid, 0);
        TogglePlayerSpectating(playerid,0);
        SetPlayerMoney(playerid, Player[playerid][malinki]);
        //SpawnPlayer(playerid);

        new year, month, day;
		getdate(year, month, day);
		
		if(year != Player[playerid][LASTYEAR] || month != Player[playerid][LASTMOUNTH] || day != Player[playerid][LASTDAY])
		{
		    Player[playerid][REPORTS] = 0;
		    Player[playerid][online] = 0;
  			new Qwery_report[144];
	    	format(Qwery_report, sizeof(Qwery_report), "UPDATE `Accounts` SET `reports` = '0' WHERE `id` = '%d'", Player[playerid][ID]);
	    	mysql_query(ConnectMySQL, Qwery_report, false);
  			new Qwery_online[144];
	    	format(Qwery_online, sizeof(Qwery_online), "UPDATE `Accounts` SET `online` = '0' WHERE `id` = '%d'", Player[playerid][ID]);
	    	mysql_query(ConnectMySQL, Qwery_online, false);
		}
        
		if(Player[playerid][ADMIN] >= 1)
		{
		    if(Player[playerid][ADMIN] < 6)
		    {
			    new string_admin[144];
				format(string_admin, sizeof(string_admin), "[%s #%d] %s[%d] ����� � ����",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid);
	  			SendAdminMessage(COLOR_ADMINCHAT, string_admin);
  			}
		}

        if(Player[playerid][MUTE] != 0)
        {
            SCM(playerid, 0xFFFF99FF, "[!!!] ��� ��� ������������ ������� ��������, ����� ������ ����� �� ������������� ����������� /time.");
        }
        if(Player[playerid][VMUTE] != 0)
        {
            SvMutePlayerEnable(playerid);
        }
        
        new Qwery[144];
	    format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `lastday` = '%d' WHERE `id` = '%d'", day, Player[playerid][ID]);
	    mysql_query(ConnectMySQL, Qwery, false);

		new Qwery1[144];
	 	format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `lastmounth` = '%d' WHERE `id` = '%d'", month, Player[playerid][ID]);
	  	mysql_query(ConnectMySQL, Qwery1, false);

		new Qwery2[144];
	 	format(Qwery2, sizeof(Qwery2), "UPDATE `Accounts` SET `lastyear` = '%d' WHERE `id` = '%d'", year, Player[playerid][ID]);
	  	mysql_query(ConnectMySQL, Qwery2, false);
    }
    else
    {
        f("{FFFFFF}���� ������� ���� � ����� ���� ������, ������������� �� ���������������\n\n��� ����������� ������� ������ � ���� ����, ������ ������ ����������\n�������, �� ��, ��� �� � ���� <3");
        SPD(playerid, 3, DIALOG_STYLE_PASSWORD, "{db2751}�����������", string,"�����","�����");
        SCM(playerid, COLOR_WHITE, "���, ������ ��������, ���������� �����");
    }
    
    if(Player[playerid][pSex] == 1)
    {
        SetPlayerColor(playerid, 0x66CCFFFF);
        SetPlayerSkin(playerid, 114);
    }
    if(Player[playerid][pSex] == 2)
    {
        SetPlayerColor(playerid, 0x663399FF);
        SetPlayerSkin(playerid, 28);
    }
    return true;
}

/*publics LoadCheckOnline(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows)
	{
		new player[24];
		cache_get_field_content(0, "name", player, ConnectMySQL, 24);
	    for(new i; i < MAX_PLAYERS; i++)
		{
			if(strcmp(player, Player[i][pName], true))
			{
			    new Query[128];
			    format(Query, sizeof(Query), "UPDATE `Accounts` SET online = '0' WHERE name = '%s' LIMIT 1", player);
			    mysql_tquery(ConnectMySQL, Query, "", "");
			}
		}
	}
	if(!rows)
	{
	 	print("�������� �� �������");
	}
	return true;
}*/

publics AdminStats(playerid)
{
    //new string[200];
    new rows;
    new rows2;
    cache_get_data(rows, rows2);
    if(!rows)
	{
 		SendClientMessage(playerid,COLOR_GREY, "������� �� ������");
	}
    else if(rows)
	{
		if(cache_get_field_content_int(0, "admin") <= 0) return SCM(playerid, COLOR_GREY, "����� �� �������� ������� ��������");
     	new dtext[320];
     	
     	new nameadm[24];
		cache_get_field_content(0, "name", nameadm, ConnectMySQL, 24);
		
		new comanda[10];
        if(cache_get_field_content_int(0, "Sex") == 1) comanda = "������";
        if(cache_get_field_content_int(0, "Sex") == 2) comanda = "��������";
        if(cache_get_field_content_int(0, "Sex") == 3) comanda = "��������";
		
	    format(dtext,sizeof(dtext),"������� ������\t\t\t\t{bfbfbf}#%d\n\
		{FFFFFF}�������\t\t\t\t\t{bfbfbf}%s\n\
		{FFFFFF}�������� �� �������\t\t\t\t{bfbfbf}%d\n\
		{FFFFFF}�������\t\t\t\t\t{bfbfbf}%s\n\
		{FFFFFF}��������� ����\t\t\t\t{bfbfbf}%d.%d.%d\n\
		{ffad5c}ID �����\t\t\t\t\t%d\n\
		{ffad5c}����� �������\t\t\t\t\t%d\n\
		{ffad5c}����� �������\t\t\t\t\t%d\n\
		{ffad5c}��������\t\t\t\t\t%d",
		cache_get_field_content_int(0, "id"),
		nameadm,
		cache_get_field_content_int(0, "reports"),
		comanda,
		cache_get_field_content_int(0, "lastday"),
		cache_get_field_content_int(0, "lastmounth"),
		cache_get_field_content_int(0, "lastyear"),
		cache_get_field_content_int(0, "Skin"),
		cache_get_field_content_int(0, "Level"),
		cache_get_field_content_int(0, "malinki"),
		cache_get_field_content_int(0, "malplus"));
	    ShowPlayerDialog(playerid, 2112, DIALOG_STYLE_LIST, "{db2751}���������� �������� �������", dtext, "�������", "");
    }
	return true;
}

publics LoadAllAdmins(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows)
	{
		new name[24],
		temp[20],
		string[625],
		AdmNumber,
		AdmLevel;

	    for(new i = 0; i < rows; i++)
	    {
			cache_get_field_content(i, "name", name, ConnectMySQL, 24);
			cache_get_field_content(i, "admin", temp), AdmLevel = strval (temp);
			cache_get_field_content(i, "id", temp), AdmNumber = strval (temp);

	    	format(string,sizeof(string),"%s{FFFFFF}[%s #%d] %s\n", string, GSName[AdmLevel], AdmNumber, name);
		}
	  	ShowPlayerDialog(playerid,2112, DIALOG_STYLE_LIST, "{db2751}������ ������� ��������", string, "�������", "");
	}
	else
	{
	    SCM(playerid, COLOR_GREY, "������� ������� �� �������");
	}
	return true;
}

publics LoadUnBan(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows)
	{
		new nameadm[24];
		cache_get_field_content(0, "name", nameadm, ConnectMySQL, 24);
	
	    new string[144];
	    format(string, sizeof(string), "������� ������ #%d ������������� ������� %s", Player[playerid][ID], nameadm);
	    SCMTA(COLOR_TOMATO, string);
	    
	    new Query[128];
	    format(Query, sizeof(Query), "UPDATE `Accounts` SET ban = '0' WHERE name = '%s' LIMIT 1", nameadm);
	    mysql_tquery(ConnectMySQL, Query, "", "");
	}
	else if(!rows)
	{
		SCM(playerid, COLOR_GREY, "�������� � ����� ����������� �� ����������");
	}
	return true;
}

publics LoadOffBan(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows)
	{
     	if(cache_get_field_content_int(0, "admin") > 6) return SCM(playerid, COLOR_GREY, "�� �� ������ ������ ������� ��������� ����� �������� �������");
	
		new nameadm[24];
		cache_get_field_content(0, "name", nameadm, ConnectMySQL, 24);

	    new string[144];
	    format(string, sizeof(string), "������� ������ #%d ������������ ������� %s �������", Player[playerid][ID], nameadm);
	    SCMTA(COLOR_TOMATO, string);

	    new Query[128];
	    format(Query, sizeof(Query), "UPDATE `Accounts` SET ban = '1' WHERE name = '%s' LIMIT 1", nameadm);
	    mysql_tquery(ConnectMySQL, Query, "", "");
	}
	else if(!rows)
	{
		SCM(playerid, COLOR_GREY, "������� �� ������");
	}
	return true;
}

publics LoadOffAdmin(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows)
	{
	    if(cache_get_field_content_int(0, "admin") >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� �� ������ ��������� ��� � ����� �������� �������!");
	    if(cache_get_field_content_int(0, "admin") < 0) return SCM(playerid, COLOR_GREY, "����� �� �������� ������� ��������");

		new nameadm[24];
		cache_get_field_content(0, "name", nameadm, ConnectMySQL, 24);

	    new string[144];
	    format(string, sizeof(string), "������� ������ #%d ���� [%s #%d] %s �������", Player[playerid][ID], GSName[cache_get_field_content_int(0, "admin")], cache_get_field_content_int(0, "id"),nameadm);
	    SendAdminMessage(COLOR_GREY, string);

	    new Query[128];
	    format(Query, sizeof(Query), "UPDATE `Accounts` SET admin = '0' WHERE name = '%s' LIMIT 1", nameadm);
	    mysql_tquery(ConnectMySQL, Query, "", "");
	}
	else if(!rows)
	{
		SCM(playerid, COLOR_GREY, "������� �� ������");
	}
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    new Float:health;
    GetPlayerHealth(killerid, health);
    SetPlayerHealth(killerid, 100.0);
    if(Player[playerid][ADMIN] <= 1 || Player[killerid][ADMIN] <= 1)
    {
		SendDeathMessage(killerid, playerid ,reason);
    }

    SetPlayerMoney(playerid, Player[playerid][malinki]);

    if(Player[playerid][malplus] == 0)
    {
        SetPlayerHealth(killerid, 100);
    }
    else
    {
        SetPlayerHealth(killerid, 130);
    }
    
	Player[killerid][pLevel] += 1;
    SetPlayerScore(killerid, Player[killerid][pLevel]);
    MysqlUpdatePlayerInt(killerid, "Level", Player[killerid][pLevel]);
    return true;
}
//=============================[Stock]==========================================
stock Registr(playerid)
{
    new string[128];
    mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `name` = '%e' AND `password` = '%e'", Player[playerid][pName], Player[playerid][pPass]);
    return mysql_function_query(ConnectMySQL, string, true, "OnLogin", "d", playerid);
    
    Player[playerid][pLevel] = 1;
    Player[playerid][ADMIN] = 0;
    Player[playerid][Spectating] = 0;
    Player[playerid][MUTE] = 0;
    Player[playerid][BAN] = 0;
    Player[playerid][malplus] = 0;
    Player[playerid][malinki] = 0;
    
    Login[playerid] = true;
    SetPVarInt(playerid, "Logged", 1);
    
}

stock Clear(playerid)
{
    Login[playerid] = false;
}
stock SetPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid, Player[playerid][pSkin]);
    SetPlayerScore(playerid, Player[playerid][pLevel]);
    if(Player[playerid][pLevel] > 0)
    {
        SetPlayerPos(playerid, 1481.5237,-1261.9025,12.9341); // ���������� ������.
        SetPlayerFacingAngle(playerid, 0);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetCameraBehindPlayer(playerid);
    }
}
//===========================[������� �������]==================================
CMD:mn(playerid)
{
    SPD(playerid, 37, DSL, "{EE3366}���� ���������", "{FFFFFF}1. ����������\n2. ����� �������\n3. �������� ������\n4. ������� �������\n5. ������� � ������", "�������", "�������");
    return true;
}

CMD:kq(playerid)
{
    if(!PlayerToPoint(50, playerid, 2381.6975,-1906.1652,22.6751)) return SCM(playerid, COLOR_GREY, "�� �� ���������� � ������");
    SCM(playerid, -1, "�� ������� �� DM ����, �������� ����");
    SpawnPlayer(playerid);
    return true;
}

stock randomEx(min, max)
{
    new rand = random(max-min)+min;
    return rand;
}


CMD:dice(playerid, params[])
{
    if(GetPVarInt(params[0],"StartGame") != 0) return SCM(playerid, COLOR_GREY, "������ ��� ��������� �������� �����������");
    if(sscanf(params,"ud",params[0],params[1])) return SendClientMessage(playerid,COLOR_GREY,"/dice [ID ������] [������]");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid,COLOR_GREY,"����� �� � ����");
    if(params[1] < 25 || params[1] > 1000) SendClientMessage(playerid,COLOR_GREY,"������ �� ����� ���� ����� 25 � ����� 1000 �������");
    if(!PlayerToPoint(50, playerid, 2381.6975,-1906.1652,22.6751)) return SCM(playerid, COLOR_GREY, "�� �� ���������� � ������");
    if(params[0] == playerid) return SCM(playerid, COLOR_GREY, "�� �� ������ ������ � ����� �����");
    if(Player[playerid][malinki] < params[1]) return SCM(playerid, COLOR_GREY, "� ��� ������������ �������");
    if(Player[params[0]][malinki] < params[1]) return SCM(playerid, COLOR_GREY, "� ������ ������������ �������");
    if(params[1] < 25) return SCM(playerid, COLOR_GREY, "����������� ������ - 25 �������");
    new string[144];
    GetPlayerName(playerid,gpname(playerid),MAX_PLAYER_NAME);
    SetPVarInt(params[0],"StartGame",1);
    SetPVarInt(playerid,"StartGame",1);
    format(string,sizeof(string),"%s ��������� ��� ������� �����. ������: %d �������",gpname(playerid),params[1]);
    SendClientMessage(params[0],0x4dcfffFF,string);
    SendClientMessage(params[0],-1,"����������� {31B404}/yes{FFFFFF}, ����� ���������� {FF6347}/no{FFFFFF}, ����� ���������");
    new string1[144];
    format(string1,sizeof(string1),"�� ���������� ������ ����� ������ %s. ������: %d �������", gpname(params[0]), params[1]);
    SendClientMessage(playerid,0x4dcfffFF, string1);
    
    KostiName[params[0]] = playerid;
    KostiMoney[params[0]] = params[1];
    return true;
}

CMD:yes(playerid, params[])
{
    if(GetPVarInt(playerid,"StartGame") != 1) return SCM(playerid, COLOR_GREY, "� ��� ��� �������� �����������");
    if(!PlayerToPoint(50, playerid, 2381.6975,-1906.1652,22.6751)) return SCM(playerid, COLOR_GREY, "�� �� ���������� � ������");

    new p1 = randomEx(1, 6);
    new p2 = randomEx(1, 6);
    if(p1 > p2)
    {
            GivePlayerMoney(playerid, -KostiMoney[playerid]);
            Player[playerid][malinki] -= KostiMoney[playerid];

            new Qwery1[144];
            format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][malinki], Player[playerid][ID]);
            mysql_query(ConnectMySQL, Qwery1, false);
            
            GivePlayerMoney(KostiName[playerid], KostiMoney[playerid]);
            Player[KostiName[playerid]][malinki] += KostiMoney[playerid];

            new Qwery[144];
            format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[KostiName[playerid]][malinki], Player[KostiName[playerid]][ID]);
            mysql_query(ConnectMySQL, Qwery, false);
            
            SCM(KostiName[playerid], -1, "�� ��������, �����������!");
            SCM(playerid, -1, "�� ���������, ���");
            SetPlayerChatBubble(KostiName[playerid], "�������", 0x31B404FF, 20.0, 3000);
            SetPlayerChatBubble(playerid, "��������", COLOR_TOMATO, 20.0, 3000);
    }
    else if(p1 < p2)
    {
            GivePlayerMoney(playerid, -KostiMoney[playerid]);
            Player[playerid][malinki] += KostiMoney[playerid];

            new Qwery1[144];
            format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][malinki], Player[playerid][ID]);
            mysql_query(ConnectMySQL, Qwery1, false);
            
            GivePlayerMoney(KostiName[playerid], KostiMoney[playerid]);
            Player[KostiName[playerid]][malinki] -= KostiMoney[playerid];

            new Qwery[144];
            format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[KostiName[playerid]][malinki], Player[KostiName[playerid]][ID]);
            mysql_query(ConnectMySQL, Qwery, false);
            
            SCM(KostiName[playerid], -1, "�� ���������, ���");
            SCM(playerid, -1, "�� ��������, �����������!");
            SetPlayerChatBubble(KostiName[playerid], "��������", COLOR_TOMATO, 20.0, 3000);
            SetPlayerChatBubble(playerid, "�������", 0x31B404FF, 20.0, 3000);
    }
    else
    {}
    
    DeletePVar(playerid,"StartGame");
    DeletePVar(KostiName[playerid],"StartGame");
    
    new str[145];
    format(str,sizeof(str),"%s � %s ������� ��������� ��������� ������ {FF9966}(%d|%d)",gpname(playerid),gpname(KostiName[playerid]),p1, p2);
    ProxDetector(playerid, 25.0, str, 0xFF99CCFF,0xFF99CCFF,0xFF99CCFF,0xFF99CCFF,0xFF99CCFF);
    return true;
}

CMD:no(playerid, params[])
{
    if(GetPVarInt(playerid,"StartGame") != 1) return SCM(playerid, COLOR_GREY, "� ��� ��� �������� �����������");
    if(!PlayerToPoint(50, playerid, 2381.6975,-1906.1652,22.6751)) return SCM(playerid, COLOR_GREY, "�� �� ���������� � ������");
    
    DeletePVar(playerid,"StartGame");
    DeletePVar(KostiName[playerid],"StartGame");
    
    SCM(KostiName[playerid], COLOR_GREY, "����� ��������� ������ � ����");
    SCM(playerid, COLOR_GREY, "�� ���������� �� ���� � �����");
    return true;
}

CMD:try(playerid, params[])
{
    new string[128];
    if(sscanf(params, "s[99]", params[0])) return SCM(playerid, COLOR_GREY, !"����������� /try [�����]");
    if(Player[playerid][MUTE] != 0)
    {
        SCM(playerid, COLOR_WHITE, "��� ������������ ������� ��������");
        SetPlayerChatBubble(playerid, "������� ��� ������������", COLOR_BLOCK, 20.0, 3000);
        return true;
    }
    format(string, sizeof(string), "%s %s %s", GN(playerid), params[0], (!random(2)) ? ("{dd4b0e}(��������)") : ("{2ec35a}(������)"));
    return ProxDetector(playerid, 20.0, string, 0xefa2caFF, 0xefa2caFF, 0xefa2caFF, 0xefa2caFF, 0xefa2caFF);
}

CMD:report(playerid,params[])
{
    if(GetPVarInt(playerid, "Logged") == 0) return true;
    if(sscanf(params, "s[144]", params[0])) return SCM(playerid, COLOR_GREY,"�����������: /report [�����].");
    if(Player[playerid][MUTE] != 0)
    {
        SCM(playerid, COLOR_WHITE, "��� ������������ ������� ��������");
        SetPlayerChatBubble(playerid, "������� ��� ������������", COLOR_BLOCK, 20.0, 3000);
        return true;
    }
    SetPVarInt(playerid,"report",gettime());
    new string2[144];
    if(GetPVarInt(playerid,"Counting_report") > gettime() ) return SendClientMessage(playerid, COLOR_GREY, "��� ������� ����� ��� � 3 ������.");
    if(Player[playerid][ADMIN] > 1) return SCM(playerid,COLOR_GREY,"������� ������� �� ����� �������� ������ � /report");
    format(string2, sizeof(string2), "������ �� %s[%d]:{FFFFFF} %s", Player[playerid][pName], playerid, params[0]);
    SendAdminMessage(COLOR_LIGHTYELLOW, string2);
    format(string2, sizeof(string2), "������ �� %s[%d]:{FFFFFF} %s", Player[playerid][pName], playerid, params[0]);
    SCM(playerid, COLOR_LIGHTYELLOW, string2);
    SetPVarInt(playerid,"Counting_report",gettime() + 180);
    return true;
}

CMD:sms(playerid, params[])
{
	if(GetPVarInt(playerid, "Logged") == 0) return true;
 	if(Player[playerid][MUTE] != 0)
    {
        SCM(playerid, COLOR_WHITE, "��� ������������ ������� ��������");
        SetPlayerChatBubble(playerid, "������� ��� ������������", COLOR_BLOCK, 20.0, 3000);
        return true;
    }
    if(GetPVarInt(playerid,"Counting_SMS") > gettime()) return SendClientMessage(playerid, COLOR_GREY, "������������ ��� ������� ����� ��� � 15 ������");
	if(sscanf(params, "is[144]", params[0], params[1])) return SCM(playerid, COLOR_GREY, "�����������: /sms [ID ������] [�����]");
 	if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, COLOR_GREY, "����� �� � ����");
 	if(params[0] == playerid) return SCM(playerid, COLOR_GREY, "�� �� ������ ��������� SMS ������ ����");

 	new string[144];
  	format(string, sizeof(string), "[SMS] %s[%d]: %s", gpname(playerid), playerid, params[1]);
    SendClientMessage(params[0], 0xffff00FF, string);
    SendClientMessage(playerid, 0xffff00FF, string);


   	new string_adm[144];
  	format(string_adm, sizeof(string_adm), "[SMS] %s[%d] > %s[%d]: {FFFFFF}%s", Player[playerid][pName], playerid, Player[params[0]][pName], params[0], params[1]);
    SendAdminMessage(0xffff00FF, string_adm);
    
   	SetPVarInt(playerid,"Counting_SMS",gettime() + 15);
	return true;
}

CMD:loc(playerid, params[])
{
        if(PlayerToPoint(50, playerid, 2381.6975,-1906.1652,22.6751)) return SCM(playerid, COLOR_GREY, "�� �� ������ ������ ������� �������� � ������");
        if(sscanf(params,"d",params[0])) return SendClientMessage(playerid, COLOR_GREY, "�����������: /loc [id �������]");
        new string[144];
        if(params[0] < 0 || params[0] > 100) return SendClientMessage(playerid, COLOR_GREY, !"�������� ������� �� 0 �� 100");
        format(string, sizeof(string), "�� ������� �� ������� #%d", params[0]);
        SCM(playerid, 0x61e8b9FF, string);
        SetPlayerVirtualWorld(playerid, params[0]);
        locvw[playerid] = GetPlayerVirtualWorld(playerid);
        return true;
}

CMD:id(playerid, params[])
{
        new
        str[390],
        name[24],
        bool:ttrue = false;

        GetPlayerName(playerid, name, sizeof(name));

        if(sscanf(params, "s[20]", params[0])) return SendClientMessage(playerid, COLOR_GREY, "�����������: /id [����� ����] (����� ID ������ �� ����)");
        foreach(new i : Player)
        {
                    format(str, sizeof(str), "%s[%d]", name, i);
    				ShowPlayerDialog(playerid, 2112, DIALOG_STYLE_LIST, "{db2751}����������", str, "�������", "");
                    ttrue = true;
        }
        if(!ttrue)
        {
                format(str, 145, "���������� �� �������");
                SendClientMessage(playerid, COLOR_GREY, str);
        }
        return 1;
}


CMD:music(playerid)
{
        ShowPlayerDialog(playerid,3873,DIALOG_STYLE_LIST, "{db2751}������ ������", "1.� ���� ����...\n2.SQWOZ BAB - ����\n3.VAC�O & OFFMi - PUNK\n4.VACIO - �����������", "��������", "������");
        return 1;
}

CMD:musicoff(playerid)
{
    StopAudioStreamForPlayer(playerid);
}

CMD:mp(playerid)
{
        if(mp == false) return SCM(playerid, COLOR_GREY, "����� ����������� ���� ������� ������� ��������");
        if(GetPVarInt(playerid, "TPMP") == 1) return SCM(playerid, 0x5cff7aFF, "�� ��� ����������������� �� �����������, ��������� ������� �����...");
        ShowPlayerDialog(playerid, 4241, DIALOG_STYLE_MSGBOX, "{db2751}�������������", "{FFFFFF}�� ������������� ������ ����������������� �� �����������?", "��", "���");
        return 1;
}

CMD:r(playerid, params[])
{
    if(Player[playerid][pSex] == 0) return 1;
    if(sscanf(params, "s[144]", params[0])) return SendClientMessage(playerid, COLOR_GREY, "�������: /r [�����]");
    if(Player[playerid][MUTE] != 0)
    {
        SCM(playerid, COLOR_WHITE, "��� ������������ ������� ��������");
        SetPlayerChatBubble(playerid, "������� ��� ������������", COLOR_BLOCK, 20.0, 3000);
        return true;
    }
    new string[144];
    format(string, sizeof(string), "(( [R] %s[%d]: %s ))", gpname(playerid), playerid, params[0]);
    SendRadioMessage(COLOR_RADIO, string, Player[playerid][pSex]);
    return 1;
}

CMD:time(playerid)
{
    ApplyAnimation(playerid,"COP_AMBIENT","Coplook_watch",4.1,0,0,0,0,0);
    new hour,minuite, second, string[144],Year, Month, Day,month[10];
    gettime(hour,minuite, second);
    getdate(Year, Month, Day);
    switch(Month)
    {
        case 1: month = "01";
        case 2: month = "02";
        case 3: month = "03";
        case 4: month = "04";
        case 5: month = "05";
        case 6: month = "06";
        case 7: month = "07";
        case 8: month = "08";
        case 9: month = "09";
        case 10: month = "10";
        case 11: month = "11";
        case 12: month = "12";
    }

    format(string,sizeof(string),"~g~%d.%s.%d ~y~%02d:%02d~n~~w~� ���� ~b~%d ���~n~~w~������ ~b~01",Day, month, Year, hour, minuite, Player[playerid][online]);
    GameTextForPlayer(playerid, string, 5000, 1);
    SetPlayerChatBubble(playerid, "������� �� ����", 0xefa2caFF, 20.0, 3000);
    
    new str[144];
    format(str, sizeof(str), "����� �� ������������� ���� %d ���", Player[playerid][MUTE]*60);
    if(Player[playerid][MUTE] != 0) return SCM(playerid, COLOR_GREY, str);
    
    new str1[144];
    format(str1, sizeof(str1), "����� �� ������������� ���������� ���� %d ���", Player[playerid][VMUTE]);
    if(Player[playerid][VMUTE] != 0) return SCM(playerid, COLOR_GREY, str1);
    
    new str2[144];
	format(str2, sizeof(str2), "���������� �������� �� �������: %d", Player[playerid][REPORTS]);
	if(Player[playerid][ADMIN] != 0) return SCM(playerid, -1, str2);
    return true;
}

CMD:shop(playerid)
{
        SPD(playerid, 9184, DSL, "{db2751}�������", "{FFFFFF}1. ���� ���������� ��\t{4dcfff}390 ���.\n\
		{FFFFFF}2. ���� ������� ���������\t{4dcfff}200 ���.\n\n\
		{FFFFFF}3. ���� ������� ������{4dcfff}\t200 ���.\n\
		{FFFFFF}4. ��������� {EE3366}Plus\t\t{4dcfff}500 ���.","������","�����");
}

CMD:mdm(playerid)
{
	return GameTextForPlayer(playerid, "~w~Catborisovv � Zuboskall", 5000, 1);
}

CMD:fuck(playerid)
{
	return SCM(playerid, 0xCCCCCCFF, "��, ���� ���� ����� ������ �� ����");
}

CMD:history(playerid)
{
	return ShowPlayerDialog(playerid, 2112, DIALOG_STYLE_MSGBOX, "{EE3366}�������", "��, ��� � ������� ������ ���������� � (Catborisovv), ���� (Zuboskall)\n\
	����������� ������� ����������� ������ ��� ���������� ��������, ��� ����� � ��������� ���������, �� � �� ������� � ���������� � �����.\n\
	��� � ��� ���������� �������, ������� �� ���...\n\n\
	{EE3366}������, ������� ���", "�������", "");
}

CMD:duel(playerid, params[])
{
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_GREY, !"����������� /duel [id ������]");
    if(GetPVarInt(params[0], "logged") != 1) return SCM(playerid, COLOR_GREY, "����� �� �����������");
    if(GetPVarInt(playerid, "DuelStart") != 0) return SCM(playerid, COLOR_GREY, "��������� ������ �����");
    if(GetPVarInt(params[0], "DuelStart") != 0) return SCM(playerid, COLOR_GREY, "����� ��� � �����");
    if(params[0] == playerid) return SCM(playerid, COLOR_GREY, "�� �� ������ ������ ����� � ����� �����");
	if(GetPVarInt(playerid,"Counting_Duel") > gettime() ) return SendClientMessage(playerid, COLOR_GREY, "������������ ��� ������� ����� ��� � 15 ������");

	new str2[144];
   	format(str2, sizeof(str2), "�� ������� �� ����� ������ %s", gpname(params[0]));
	SCM(playerid, 0x00bfffFF, str2);
    
    new dtext[144];
    format(dtext,sizeof(dtext), "{FFFFFF}%s �������� ��� ��������� � ��� � �����.", gpname(playerid));
    ShowPlayerDialog(params[0], 3128, DIALOG_STYLE_MSGBOX, "{EE3366}�����", dtext, "�������", "�������");
    
	SetPVarInt(params[0], "DuelRivalDialog", playerid);
	SetPVarInt(playerid,"Counting_Duel",gettime() + 3);
	return true;
}

CMD:duelstop(playerid)
{
	if(GetPVarInt(playerid, "DuelStart") == 0) return SCM(playerid, COLOR_GREY, "�� �� � �����");
    SetPVarInt(GetPVarInt(playerid, "DuelRival"), "DuelStart", 0);
    SetPVarInt(playerid, "DuelStart", 0);

	new string1[144];
	format(string1, sizeof(string1), "[DUEL] %s[%d] > %s[%d]: {dd4b0e}����� �����������", gpname(GetPVarInt(playerid, "DuelRival")), GetPVarInt(playerid, "DuelRival"), gpname(playerid), playerid);
	SendAdminMessage(COLOR_YELLOW, string1);
    
    SpawnPlayer(playerid);
    SpawnPlayer(GetPVarInt(playerid, "DuelRival"));
    
	return SCM(playerid, -1, "�� ��������� �����");
}

CMD:gift(playerid)
{

	new simvol1[200] = {
		"{FFFFFF}������� �� ��������� � ���� � ����� �������  �������� ����� ������ � ���� ������� ������!\n\
		���� �������� �������� ������� ��� ���� ������, ���� ��� ��� �����, ������� �� �� �����,"
	};

	new simvol2[200] = {
		"��� ����� ������� ������������� �����! �� ������� ������ � � ���� ���� ���� �\n\
		���� �������� ��� ���� ����, ����� ������� �� ���� ��������� � ��������!"
	};

	new simvol3[250] = {
		"������  ��������� ������� ���� �� ���� ������:�����\n\
		�������� ��������� ����� ����������������� �� ��������� �����"
	};

	new simvol4[300] = {
		"� ��� ������ ��������,� ��� ����� ���� �������, ������������.\n\n\
		{FFFF99}������� � ��������� ����� � ���� ������ ���!"
	};

    new simvol[200+200+250+300];

    format(simvol,sizeof(simvol),"%s\n%s\n%s\n%s", simvol1, simvol2, simvol3, simvol4);
    ShowPlayerDialog(playerid, 2112, DSM, "{EE3366}����� 9 ���", simvol, "�������", "");
    return true;
}

//================������� ������� ��������=====================

CMD:prison(playerid, params[])
{
    if(Player[playerid][ADMIN] < 4) return 1;
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_GREY, !"����������� /prison [id ������]");
    if(GetPVarInt(params[0], "logged") != 1) return SCM(playerid, COLOR_GREY, "����� �� �����������");
    if(Player[params[0]][ADMIN] != 0) return SCM(playerid, COLOR_GREY, "�� �� ������ ������ ��������� �������� �������");
    if(params[0] == playerid) return SCM(playerid, COLOR_GREY, "�� �� ������ ������ ��������� ������ ����");
    SetPVarInt(playerid, "PrisonID", params[0]);

	new simvol1[200] = {
		"�\t\t\t��������\t\t\t�������\n\
	    1\t������\t\t\t\t\t\t\t\t\t/kick id ������ (�. 1.1)\n\
	    2\t������\t\t\t\t\t\t\t\t\t/kick id ������ (�. 1.2)\t\n\
	    3\t����� � ����������\t\t\t\t\t\t\t/kick id ����� �� ������� ���� (� 1.3)"
	};
	
	new simvol2[200] = {
		"4\t����\t\t\t\t\t\t\t\t\t/ban id ���� (�. 1.5)\n\
	    5\t����� ��\t\t\t\t\t\t\t\t\t/ban id ����� �� (�. 1.8)\n\
		6\t����������� ��\t\t\t\t\t\t\t/ban id ����������� �� (�. 1.11)\n\
	    7\t������\t\t\t\t\t\t\t\t\t/mute id 120 ������ (�. 2.5)"
	};
	
	new simvol3[250] = {
		"8\t����������� � ����\t\t\t\t\t\t\t\t\t/mute id 120 ����������� (�.2.4)\n\
		9\t�������\t\t\t\t\t\t\t\t\t/mute id 180 ������� (�. 2.6)\n\
		10\t������ � ��������� ���\t\t\t\t\t\t\t\t/vmute id 60 ������ (�. 2.9)"
	};
	
	new simvol4[300] = {
		"11\t������������ ���������\t\t\t\t\t\t\t\t/vmute id 60 ������������ ��������� (�. 2.10)\n\
		12\t�� ����������� ��������\t\t\t\t\t\t\t\t/vmute id 5 ��������� �������� (�. 2.11)\n\
		13\t����������� �������\t\t\t\t\t\t\t\t\t/vmute id 120 ����������� (�. 2.12)\n\
		14\t���������� ������\t\t\t\t\t\t\t\t\t/vmute id 180 ���������� ������ (�. 2.13)"
	};

    new simvol[200+200+250+300];

    format(simvol,sizeof(simvol),"%s\n%s\n%s\n%s", simvol1, simvol2, simvol3, simvol4);
    ShowPlayerDialog(playerid, 5213, DIALOG_STYLE_TABLIST_HEADERS, "{db2751}������ ���������", simvol, "��������", "������");
    return 1;
}

CMD:msg(playerid, params[])
{
    //if(GetPVarInt(playerid, "Logged") == 0) return true;
    if(Player[playerid][ADMIN] < 4) return true;
    if(sscanf(params, "s[124]", params[0])) return SendClientMessage(playerid, 0xa8a8a8FF, "�����������: /msg [�����]");
    if(sscanf(params, "s[144]", params[0])) return SCM(playerid, 0xa8a8a8FF, "�����������: /msg [�����]");
    new string[300];
    format(string, sizeof(string), "������� ������ #%d: %s", Player[playerid][ID], params[0]);
    SendClientMessageToAll(0xdb2751FF, string);
    return true;
}

CMD:pay(playerid, params[])
{
    if(sscanf(params,"ud",params[0],params[1])) return SCM(playerid, COLOR_GREY,"�����������: /pay [�� ������] [�����]");
    if(Player[playerid][ADMIN] < 2) return true;
    else if(params[1] < 1 || params[1] > 3000) return SCM(playerid, COLOR_GREY, "������ �������� ������ 1 � ������ 3000 �������");
    else if(params[0] == playerid) return SCM(playerid,COLOR_GREY, "�� ������� ���� ��");
    else if(!IsPlayerConnected(params[0])) return SCM(playerid,COLOR_GREY, "����� �� ������");
    if(GetPlayerMoney(playerid) < params[1]) return SCM(playerid,-1, "�� ����� ����� ������������ �������.");
    if(GetPVarInt(playerid, "Logged") == 0) return true;
    GivePlayerMoney(playerid,-params[1]); // ���� ������� ������ ��������
    GivePlayerMoney(params[0],params[1]); // ���� ������� ������ ��������

    new string[120];
    format(string,sizeof(string), "������� ������ #%d ������� ��� %d �������", Player[playerid][ID], params[1]);// ���� �������� �� ��� ������
    SCM(params[0],0x3377CCFF, string);
    new money_str[120];
    format(money_str,sizeof(money_str), "+%i �������",params[1]); // �������� �� ���
    SetPlayerChatBubble(params[0],money_str,0x24ff78FF,20.0,10000);

    format(string,sizeof(string), "[%s #%d] %s[%d] ������� %s[%d] %d �������",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid, gpname(params[0]),params[0], params[1]);// ���� �������� �� ��� ������
    SendAdminMessage(COLOR_GREY, string);

    Player[playerid][malinki] = GetPlayerMoney(playerid);

    new Qwery1[144];
    format(Qwery1, sizeof(Qwery1), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[playerid][ID], Player[playerid][malinki]);
    mysql_query(ConnectMySQL, Qwery1, false);

    Player[params[0]][malinki] = GetPlayerMoney(playerid);

    new Qwery[144];
    format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `malinki` = '%d' WHERE `id` = '%d'", Player[params[0]][ID], Player[params[0]][malinki]);
    mysql_query(ConnectMySQL, Qwery, false);

    return 1;
}

CMD:a(playerid, params[])
{
    if(Player[playerid][ADMIN] < 1) return true;

    if(sscanf(params, "s[144]", params[0])) return SCM(playerid, 0xa8a8a8FF, "�����������: /a [�����]");
    new string[144];
    format(string, sizeof(string), "[%s #%d] %s[%d]: %s", GSName[Player[playerid][ADMIN]], Player[playerid][ID],Player[playerid][pName], playerid, params[0]);
    SendAdminMessage(COLOR_BLUE, string);
    return true;
}

CMD:ans(playerid, params[])
{
    if(GetPVarInt(playerid, "Logged") == 0) return true;
    if(Player[playerid][ADMIN] < 1) return true;
    if(sscanf(params, "is[144]", params[0], params[1])) return SCM(playerid, COLOR_GREY, "�������: /ans [ID ������] [�����]");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid,COLOR_GREY,"������ ��� �� �������, �� �� ������ �������� ���");
    if(params[0] == playerid) return SendClientMessage(playerid,COLOR_GREY,"������� ������� �� ����� �������� ����� ����");
    if(Player[params[0]][ADMIN] > 0) return SendClientMessage(playerid,COLOR_GREY,"�� �� ������ �������� �������� �������");
    
    Player[playerid][REPORTS] += 1;
    
    new Qwery_report[144];
	format(Qwery_report, sizeof(Qwery_report), "UPDATE `Accounts` SET `reports` = '%d' WHERE `id` = '%d'", Player[playerid][REPORTS], Player[playerid][ID]);
	mysql_query(ConnectMySQL, Qwery_report, false);
    
    new string[144];
    format(string, sizeof(string), "[%s #%d] %s[%d] > %s[%d]: {FFFFFF}%s", GSName[Player[playerid][ADMIN]], Player[playerid][ID],Player[playerid][pName], playerid, gpname(params[0]), params[0], params[1]);
    SendAdminMessage(0x782f2fff, string);
    new string1[144];
    format(string1, sizeof(string1), "������� ������ #%d ������� ���: {FFFFFF}%s", Player[playerid][ID], params[1]);
    SCM(params[0], 0x782f2fff, string1);
    return true;
}

CMD:givegun(playerid, params[])
{
    if(Player[playerid][ADMIN] < 4) return true;
    new
        targetid,
        weaponid,
        ammo
    ;
    if(sscanf(params, "udd", targetid, weaponid, ammo))
        SendClientMessage(playerid, -1, "�����������: /givegun [playerid] [weaponid] [ammo]");
    if(IsPlayerConnected(targetid) == 0)
        return SendClientMessage(playerid, COLOR_GREY, "������ ��� �� �������");
    if(weaponid > 47 || weaponid < 1)
        return SendClientMessage(playerid, COLOR_GREY, "������ ������ �� ����������.");
    GivePlayerWeapon(targetid, weaponid, ammo);
    static const
        fmt_str[] = "[%s #%d] %s[%d] ����� %s[%d] %s[id: %d] (%d ��)"
    ;
    new
        str[sizeof(fmt_str) -(2 * 2) + (MAX_PLAYER_NAME * 2) - 2 + 18 - 2 + 12],
        playername[MAX_PLAYER_NAME],
        targetname[MAX_PLAYER_NAME],
        weaponname[18]
    ;

    GetPlayerName(playerid, playername, MAX_PLAYER_NAME);
    GetPlayerName(targetid, targetname, MAX_PLAYER_NAME);
    GetWeaponName(weaponid, weaponname, 18);
    format(str, sizeof(str), fmt_str, GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid, targetname, targetid, weaponname, weaponid, ammo);
    return SendAdminMessage(COLOR_ADMINCHAT, str);
}

CMD:g(playerid, params[])
{
    if(Player[playerid][ADMIN] < 1) return true;
    if(sscanf(params,"d",params[0])) return SendClientMessage(playerid, COLOR_GREY, "�����������: /g [id]");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid,COLOR_GREY,"������ ��� �� �������, �� �� ������ ����������������� � ����");
    if(params[0] == playerid) return SendClientMessage(playerid,COLOR_GREY,"�� �� ������ ����������������� � ������ ����");
    if(GetPVarInt(playerid,"Counting") > gettime() ) return SendClientMessage(playerid, COLOR_GREY, "������������ ��� ������� ����� ��� � 5 ������.");
    //

    
    
    
    
    

    new Float:x,Float:y,Float:z;
    new intid, worldid;
    GetPlayerPos(params[0], x, y, z);
    worldid = GetPlayerVirtualWorld(params[0]);
    intid = GetPlayerInterior(params[0]);
    SetPlayerVirtualWorld(playerid, worldid);
    SetPlayerInterior(playerid, intid);
    SetPlayerPos(playerid, x+2, y, z);
    new string[128];
    format(string, sizeof(string), "[%s #%d] %s[%d] ���������������� � %s[%d]",GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName],playerid, gpname(params[0]), params[0]);
    SendAdminMessage(COLOR_ADMINCHAT, string);
    SetPVarInt(playerid,"Counting",gettime() + 5);
    return true;
}

CMD:gethere(playerid, params[])
{
    if(Player[playerid][ADMIN] < 2) return true;
    if(sscanf(params,"d",params[0])) return SendClientMessage(playerid, COLOR_GREY, "�����������: /gethere [�� ������]");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid,COLOR_GREY,"������ ��� �� �������, �� �� ������ ��������������� ��� � ����");
    if(params[0] == playerid) return SendClientMessage(playerid,COLOR_GREY,"�� �� ������ ��������������� ����");
    if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� �� ������ ��������� ��� � ����� �������� �������!");
    //

    
    
    
    
    

    new Float:x,Float:y,Float:z;
    new intid;
    GetPlayerPos(playerid, x, y, z);
    intid = GetPlayerInterior(playerid);
    SetPlayerInterior(params[0], intid);
    SetPlayerPos(params[0], x+2, y, z);
    new string[128];
    format(string, sizeof(string), "[%s #%d] %s[%d] �������������� � ���� %s[%d]", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName],playerid,  gpname(params[0]), params[0]);
    SendAdminMessage(COLOR_ADMINCHAT, string);
    getherevw[playerid] = GetPlayerVirtualWorld(playerid);
    SetPlayerVirtualWorld(params[0], getherevw[playerid]);
    format(string, 128, "�� ���� ��������������� ������� ��������");
    SendClientMessage(params[0], COLOR_WHITE, string);
    return true;
}

CMD:slap(playerid, params[])
{
    if(Player[playerid][ADMIN] < 1) return true;
    new string[128];
    new Float:shealth, Float:Slap_x, Float:Slap_y, Float:Slap_z;

    if(GetPVarInt(playerid,"Counting_slap") > gettime() ) return SendClientMessage(playerid, COLOR_GREY, "������������ ��� ������� ����� ��� � 3 �������.");
    if(sscanf(params, "u", params[0])) return SCM(playerid, COLOR_GREY, "�������������: /slap [ID]");
    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_GREY, "����� �� � ����!");
    if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� �� ������ ��������� ��� � ����� �������� �������!");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");

    GetPlayerHealth(params[0], shealth);
    GetPlayerPos(params[0], Slap_x, Slap_y, Slap_z);
    SetPlayerPos(params[0], Slap_x, Slap_y, Slap_z + 5);
    PlayerPlaySound(params[0], 1130, Slap_x, Slap_y, Slap_z + 5);
    format(string, sizeof(string), "[%s #%d] %s[%d] �������� ������ %s[%d] (5 ������)", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName],playerid, gpname(params[0]), params[0]);
    SendAdminMessage(COLOR_WHITE, string);
    SetPVarInt(playerid,"Counting_slap",gettime() + 3);
    return true;
}

CMD:kick(playerid, params[])
{
    if(Player[playerid][ADMIN] < 2) return true;
    new string[128];

    if(sscanf(params, "dS()[38]", params[0], params[1])) return SCM(playerid, COLOR_GREY, "�����������: /kick [id] [�������]");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid,COLOR_GREY,"������ ��� �� �������, ��������� ��������� id ������");
    if(params[0] == playerid) return SendClientMessage(playerid,COLOR_GREY,"�� �� ������ ������� ����");
    if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "� ����� ���� ��� ������?");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");




    
    
    format(string, sizeof(string), "������� ������ #%d ������ ������ %s. �������: %s", Player[playerid][ID], gpname(params[0]), params[1]);
    SCMTA(COLOR_BLOCK, string);
    TogglePlayerSpectating(params[0],1);
    Kick(params[0]);
    return true;
}

CMD:weather(playerid)
{
        if(Player[playerid][ADMIN] < 2) return  true;
        ShowPlayerDialog(playerid,4385,DIALOG_STYLE_LIST, "{db2751}��������� ������", "1.��������� ������\n2.����� ������\n3.�����\n4.�������� � �����\n5.������ � ���������\n6.�������� ���� \n7.�������� � �����������\n8.� ������� �������� ���������\n9.������\n10.������� � ���� \n11.������ ������� ���������� \n12.������� ����", "�������", "������");
        return true;
}

CMD:makeadmin(playerid, params[])
{
        if(Player[playerid][ADMIN] < 6) return true;
        new string[128];
        if(sscanf(params, "ii", params[0], params[1])) return SCM(playerid, COLOR_GREY, "�����������: /makeadmin [0-2]");
        if(params[1] < 0 || params[1] > 6) return SCM(playerid, COLOR_GREY, "������� �������� ������� �� 0 �� 6");
        if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_GREY, "������ ��� � ����, �� �� ������ ��������� ��� ������� ��������");
        if(params[0] == playerid) return SCM(playerid, -1, "�����������, � ����� �� ��� ������� � �����?");

        new Qwery[144];
        Player[params[0]][ADMIN] = params[1];
        format(Qwery, sizeof(Qwery), "UPDATE `Accounts` SET `admin` = '%d' WHERE `id` = '%d'", Player[params[0]][ADMIN], Player[params[0]][ID]);
        mysql_query(ConnectMySQL, Qwery, false);
        format(string, sizeof(string), "������� ������� ������ ������� ��� ������� ��'�");
        SCM(params[0], COLOR_WHITE, string);
        format(string, sizeof(string), "[%s #%d] %s[%d] ������� ������� �������� ������� ��� %s[%d]", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName], playerid, gpname(params[0]), params[0]);
        SendAdminMessage(COLOR_GREY, string);
        return true;
}

CMD:tp(playerid)
{
        if(Player[playerid][ADMIN] < 1) return  true;
        ShowPlayerDialog(playerid,4386,DIALOG_STYLE_LIST, "{db2751}������������", "1.������� � ���� ��\n2.������� � ���� ��", "�������", "������");
        return true;
}

stock asdialog(playerid)
{
        if(Player[playerid][ADMIN] < 1) return  true;
        new aaction[80];
        new dtext[320];
        switch(Player[playerid][HideMe])
        {
            case 0: format(aaction,sizeof(aaction),"1. {FFFFFF}������ ���\t\t\t\t\t{FF6347}���������\t\t\t\t");
            case 1: format(aaction,sizeof(aaction),"1. {FFFFFF}������ ���\t\t\t\t\t{24ff78}��������\t\t\t\t");
        }
        format(dtext,sizeof(dtext),"%s\n2. ��������� �������� �� ���������\t�������",aaction);
        ShowPlayerDialog(playerid, 7213, DIALOG_STYLE_LIST, "{db2751}��������� �������� �������", dtext, "��������", "�����");
        return true;
}

forward adialogtime(playerid);
public adialogtime(playerid)
{
    asdialog(playerid);
    return true;
}

CMD:as(playerid)
{
		if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
        SetTimerEx("adialogtime", 50, 0, "d", playerid);
        return true;
}

CMD:stats(playerid, params[])
{
    if(Player[playerid][ADMIN] < 1) return true;
    if(sscanf(params,"iii", params[0])) return SCM(playerid, COLOR_GREY, "�����������: /stats [�� ������]");
    if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� �� ������ �������� ���������� ����� ������");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, COLOR_GREY, "����� �� � ����.");
    
    new malpluscheck[11];
    if (Player[params[0]][malplus] == 0) malpluscheck = "���";
    if (Player[params[0]][malplus] == 1) malpluscheck = "�������";

    new dtext[320];
    format(dtext,sizeof(dtext),"1. ����� ��������\t\t\t{FFFF99}#%d\n{FFFFFF}2. �������\t\t\t\t{3377CC}%s\n{FFFFFF}3. ������\t\t\t\t%s\n4. ��������\t\t\t\t%s\n5. �������\t\t\t\t%d", Player[params[0]][ID], Player[params[0]][pName], GSName[Player[params[0]][ADMIN]], malpluscheck, Player[params[0]][malinki]);
    ShowPlayerDialog(playerid, 2112, DIALOG_STYLE_LIST, "{db2751}����������", dtext, "�������", "");
    return true;
}

CMD:statsadmin(playerid, params[])
{
	if(Player[playerid][ADMIN] < 6) return true;
	if(sscanf(params,"iii", params[0])) return SCM(playerid, COLOR_GREY, "�����������: /statsadmin [����� ��]");
	new string[144];
	mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `id` = '%d'", params[0]);
 	return mysql_tquery(ConnectMySQL, string, "AdminStats", "d", playerid);
}

CMD:alladmins(playerid)
{
	if(Player[playerid][ADMIN] < 6) return true;
 	mysql_function_query(ConnectMySQL, "SELECT * FROM `Accounts` WHERE `admin` != '0'", true, "LoadAllAdmins", "d", playerid);
 	return true;
}

CMD:veh(playerid, params[])
{
    if(Player[playerid][ADMIN] < 5) return true;
    new string[100];
    new Float: X, Float: Y, Float: Z, Float: Angle;
    if(sscanf(params,"iii", params[0], params[1], params[2])) return SCM(playerid, COLOR_GREY, "�����������: /veh [id] [���� #1] [���� #2]");
    if(params[0] < 400 || params[0] > 611) return SCM(playerid, COLOR_GREY, "ID ������ ������ ���� �� 400 �� 611!");
    if(params[1] < 0 || params[1] > 255) return SCM(playerid, COLOR_GREY, "ID ������ ������ ���� �� 0 �� 255!");
    if(params[2] < 0 || params[2] > 255) return SCM(playerid, COLOR_GREY, "ID ������ ������ ���� �� 0 �� 255!");

    
    
    
    
    

    GetPlayerFacingAngle(playerid, Angle);
    GetPlayerPos(playerid, X,Y,Z);
    AVeh[playerid] = CreateVehicle(params[0], X, Y, Z, Angle, params[1], params[2], 99999);
    PutPlayerInVehicle(playerid, AVeh[playerid], GetPlayerVirtualWorld(playerid));
    format(string, sizeof(string), "[%s #%d] %s[%d] ������ ���������[%d] (id: %d, ����: %d, %d)", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName],playerid, GetPlayerVehicleID(playerid), params[0], params[1], params[2]);
    SendAdminMessage(COLOR_ADMINCHAT, string);
    return true;
}

CMD:dveh(playerid)
{
    if(Player[playerid][ADMIN] < 2) return true;
    
    
    
    
    
    
    
    DestroyVehicle(GetPlayerVehicleID(playerid));
    new string[144];
    format(string, sizeof(string), "[%s #%d] %s[%d] ������ ���������[%d]", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName],playerid, GetPlayerVehicleID(playerid));
    SendAdminMessage(COLOR_ADMINCHAT, string);
    return true;
}

/*CMD:sban(playerid, params[])
{
    if(Player[playerid][ADMIN] < 7) return true;

    if(sscanf(params,"iii", params[0])) return SCM(playerid, COLOR_GREY, "�����������: /sban [������]");
    if(params[0] == playerid) return SCM(playerid, COLOR_GREY, "�����������, � ����� �� ��� ������� � �����?");
    if(!IsPlayerConnected(params[0])) return SCM(playerid, COLOR_GREY, "������ ��� � ����, �� �� ������ ������������� ��� gpci id");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
    new serial[164];
    //new targetid;
    gpci(params[0], serial, sizeof(serial));
    new File:sfile = fopen("SerialBans.txt", io_readwrite);
    new sstring[162];
    new string[144];

    
    
    
    
    

    format(sstring, sizeof(sstring), "%s // (%s)[%d]\n", serial, gpname(params[0]), params[0]);
    fwrite(sfile, sstring); fclose(sfile);
    sstring[0] = EOS;
    format(string, sizeof(string), "[%s #%d] %s[%d] ������������ gpci id ������ %s[%d]", GSName[Player[playerid][ADMIN]], Player[playerid][ID], gpname(playerid),playerid, gpname(params[0]), params[0]);
    SendAdminMessage(COLOR_BLOCK, string);
    SCM(params[0], COLOR_GREY, "��� ������� ������������ ����� �� �� ������ ���������� �� �������...");
    TogglePlayerSpectating(params[0],1);
    Kick(params[0]);
    return 1;
}*/

CMD:serials(playerid)
{
    if(Player[playerid][ADMIN] < 6) return true;
    if(!fexist("SerialBans.txt")) return SendClientMessage(playerid, COLOR_GREY, "�� ������� ��� ��������������� gpci id");
    new banstr[512], File:file = fopen("SerialBans.txt", io_read);
    SendClientMessage(playerid, COLOR_WHITE, "������ �������������� gpci �������:");
    if(file)
    {
        fread(file, banstr); fclose(file); if(strlen(banstr) < 2) return SendClientMessage(playerid, 0xFFFFFFFF, "��������������� gpci id ���");
        file = fopen("SerialBans.txt", io_read);
        while(fread(file, banstr)) SendClientMessage(playerid, 0xFFFFFFFF, banstr);
        fclose(file);
    }
    return 1;
}


CMD:sp(playerid, params[])
{
        if(Player[playerid][ADMIN] < 1) return 1;
        if(sscanf(params, "u", params[0]))
        {
            if(GetPVarInt(playerid, "SET_ADM_POS") == 0) return SCM(playerid, COLOR_GREY, "�����������: /sp [�� ������]");
            //if(params[0] == playerid) return SendClientMessage(playerid,COLOR_GREY,"� ����� ���� ������� �� �����? �� �� ������ ����� ���������");
            TogglePlayerSpectating(playerid, false);
            
            SetPVarFloat(playerid, "SET_ADM_POS", 0);
            
            PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][0]);
            PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][1]);
            PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][2]);
            PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][3]);
            PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][4]);
            
            Player[playerid][Spectating][0] = -1;
            KillTimer(UpdateSpecTimer[playerid]);
            
            SetPlayerPos(playerid, GetPVarFloat(playerid, "re_X"), GetPVarFloat(playerid, "re_Y"), GetPVarFloat(playerid, "re_Z"));
            SetPlayerInterior(playerid, GetPVarInt(playerid, "re_int"));
            SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "re_virt"));
            
            return true;
        }
        if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, COLOR_GREY, "����� �� � ����.");

        if(GetPVarInt(playerid, "SET_ADM_POS") == 0) 
        {
            new Float: reX, Float: reY, Float: reZ, Float: reA;
            GetPlayerPos(playerid, reX, reY, reZ);
            GetPlayerFacingAngle(playerid, reA);

            SetPVarFloat(playerid, "re_X", reX);
            SetPVarFloat(playerid, "re_Y", reY);
            SetPVarFloat(playerid, "re_Z", reZ);
            SetPVarFloat(playerid, "re_A", reA);

            SetPVarInt(playerid, "re_int", GetPlayerInterior(params[0]));
            SetPVarInt(playerid, "re_virt", GetPlayerVirtualWorld(params[0]));
        }
        
        if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "����� ���� �� ��� �������? � ����� �� ������?");
        if(params[0] == playerid) return SCM(playerid, COLOR_GREY, "�� �� ������ ������� �� �����");
        
        SetPlayerFlyStatus(playerid, 0);
        
        TogglePlayerSpectating(playerid, true);
        SetPlayerInterior(playerid, GetPlayerInterior(params[0]));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(params[0]));

        if(IsPlayerInAnyVehicle(params[0]))

        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(params[0]), 1);
                else
        PlayerSpectatePlayer(playerid, params[0], 1);

        Player[playerid][Spectating][0] = params[0];
        
        SCM(playerid, 0xd5b535FF, "��������: {4472c3}L.SHIFT{d5b535}, �����: {4472c3}/sp");
    
        UpdateSpecTimer[playerid] = SetTimerEx("UpdateSpec",200,1,"d",playerid);
        
        PlayerTextDrawShow(playerid, textinfo_TD_PTD[playerid][0]);
        PlayerTextDrawShow(playerid, textinfo_TD_PTD[playerid][1]);
        PlayerTextDrawShow(playerid, textinfo_TD_PTD[playerid][2]);
        PlayerTextDrawShow(playerid, textinfo_TD_PTD[playerid][3]);
        PlayerTextDrawShow(playerid, textinfo_TD_PTD[playerid][4]);

        return SetPVarInt(playerid, "SET_ADM_POS", 1);
}

CMD:tempskin(playerid, params[])
{
    if(Player[playerid][ADMIN] < 6) return 1;
    
    new string[144];
    new string1[144];

    if(sscanf(params,"ud", params[0],params[1])) return SCM(playerid, COLOR_GREY, "�����������: /tempskin [�� ������] [�� �����]");
    if(params[1] < 1 || params[1] > 299) return SCM(playerid, COLOR_GREY, "�� ������ ���������� � 1 �� 299");
    
    format(string, sizeof(string), "[%s #%d] %s[%d] ����� ��������� ���� %s[%d] (#%d)", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName],playerid, gpname(params[0]), params[0], params[1]);
    SendAdminMessage(COLOR_ADMINCHAT, string);
    
    format(string1, sizeof(string1), "������� ������ #%d ����� ��� ��������� ���� (#%d)", Player[playerid][ID], params[1]);
    SendClientMessage(params[0], -1, string1);
    
    Player[params[0]][pSkin] = params[1];
    SetPlayerSkin(params[0], params[1]);
    return true;
}

CMD:setmp(playerid)
{
        if(Player[playerid][ADMIN] < 5) return 1;
        if(mp == false)
        {
                GetPlayerPos(playerid, tpmp[0], tpmp[1], tpmp[2]);
                SendClientMessageToAll(0x5cff7aFF, "������� ������ ������ ����� �����������, ��� ������������ ������� /mp");
                mpvw[playerid] = GetPlayerVirtualWorld(playerid);
                SetPlayerVirtualWorld(playerid, 555);
                return mp = true;
        }
        else
        {
            foreach(new x: Player)
            {
                    SetPVarInt(x, "TPMP", 0);
            }
            SendClientMessageToAll(COLOR_GREY, "������� ������ ������ ����� �����������");
            return mp = false;
        }
}

CMD:gunall(playerid, params[])
{
	if(Player[playerid][ADMIN] < 5) return 1;
	
 	new radius,gun,ammon;
	if(sscanf(params, "udd", radius, gun, ammon)) return SCM(playerid, COLOR_GREY, "�������: /gunall [������] [ID ������] [�������]");
	
	new weaponid, ammo;
	weaponid = params[1];
	ammo = params[2];
	
 	if(weaponid > 47 || weaponid < 1) return SendClientMessage(playerid, COLOR_GREY, "������ ������ �� ����������.");
	
	new Float:posX, Float:posY, Float:posZ;
 	GetPlayerPos(playerid, Float:posX, Float:posY, Float:posZ);
    for(new i; i < MAX_PLAYERS; i++)
	{
		if (!IsPlayerConnected(i)) continue;
		if(PlayerToPoint(params[0], i, Float:posX, Float:posY, Float:posZ))
		{
			if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
		    {
	            GivePlayerWeapon(i, weaponid, ammo);

				new string1[144];
	            format(string1, sizeof(string1), "������� ������ #%d ����� ��� ������", Player[playerid][ID]);
	    		SendClientMessage(i, -1, string1);
			}
		}
	}
	return true;
}

CMD:hpall(playerid, params[])
{
	if(Player[playerid][ADMIN] < 5) return 1;
	
    new radius, hp;
	if(sscanf(params, "ui", radius, hp)) return SendClientMessage(playerid, COLOR_GREY, "�����������: /gunall [������] [���-�� ��������]");
	if(params[1] < 0 || params[1] > 100) return SCM(playerid, COLOR_GREY, "������� �������� �� 0 �� 100");
	new Float:posX, Float:posY, Float:posZ;
 	GetPlayerPos(playerid, Float:posX, Float:posY, Float:posZ);
    for(new i; i < MAX_PLAYERS; i++)
	{
		if(PlayerToPoint(params[0], i, Float:posX, Float:posY, Float:posZ))
		{
			if (!IsPlayerConnected(i)) continue;
		    if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
		    {
	            SetPlayerHealth(i, params[1]);

	            new string1[144];
	            format(string1, sizeof(string1), "������� ������ #%d ������� ��� ������� ��������", Player[playerid][ID]);
	    		SendClientMessage(i, -1, string1);
    		}
		}
	}
	return true;
}

CMD:armorall(playerid, params[])
{
	if(Player[playerid][ADMIN] < 5) return 1;

    new radius, armor;
	if(sscanf(params, "ui", radius, armor)) return SendClientMessage(playerid, COLOR_GREY, "�����������: /armorall [������] [���-�� �����]");
	if(params[1] < 0 || params[1] > 100) return SCM(playerid, COLOR_GREY, "������� ����� �� 0 �� 100");
	new Float:posX, Float:posY, Float:posZ;
 	GetPlayerPos(playerid, Float:posX, Float:posY, Float:posZ);
    for(new i; i < MAX_PLAYERS; i++)
	{
		if(PlayerToPoint(params[0], i, Float:posX, Float:posY, Float:posZ))
		{
			if (!IsPlayerConnected(i)) continue;
		    if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
		    {
	            SetPlayerArmour(i, params[1]);

	            new string1[144];
	            format(string1, sizeof(string1), "������� ������ #%d ������� ��� ������� �����", Player[playerid][ID]);
	    		SendClientMessage(i, -1, string1);
    		}
		}
	}
	return true;
}

CMD:spawnall(playerid, params[])
{
	if(Player[playerid][ADMIN] < 5) return 1;
	if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_GREY, "�����������: /spawnall [������]");
	new Float:posX, Float:posY, Float:posZ;
 	GetPlayerPos(playerid, Float:posX, Float:posY, Float:posZ);
    for(new i; i < MAX_PLAYERS; i++)
	{
		if (!IsPlayerConnected(i)) continue;
		if(PlayerToPoint(params[0], i, Float:posX, Float:posY, Float:posZ))
		{
		    if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
		    {
			    GameTextForPlayer(i, "~b~�������", 5000, 1);
			    SpawnPlayer(i);
    		}
		}
	}
	return true;
}

CMD:restart(playerid)
{
          if(Player[playerid][ADMIN] < 7) return true;
          Restart();
          return true;
}

CMD:spawn(playerid, params[])
{
    new string[128];

    if(Player[playerid][ADMIN] < 1) return 1;
    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_GREY, "�����������: /spawn [id ������]");
    if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� �� ������ ��������� ��� � ����� �������� �������!");
    SpawnPlayer(params[0]);
    format(string, sizeof(string), "[%s #%d] %s[%d] ��������� %s[%d] ", GSName[Player[playerid][ADMIN]], Player[playerid][ID], Player[playerid][pName],playerid, gpname(params[0]), params[0]);
    SendAdminMessage(COLOR_GREY, string);
    
    GameTextForPlayer(params[0], "~b~�������", 5000, 1);
    
    return 1;
}

CMD:ahelp(playerid)
{
        if(Player[playerid][ADMIN] < 1) return 1;
        SPD(playerid, 9828, DSL, "{EE3366}������� �������� �������", "{FFFFFF}1. NGM\n2. JRGM\n3. GM\n4. GM+\n5. LGM\n6. SGM","�����","������");
        return true;
}


CMD:admins(playerid)
{
    if(Player[playerid][ADMIN] < 1) return true;
    SCM(playerid, COLOR_BLUE, "������� ������� ������");
    new string[512];
    for(new i; i < MAX_PLAYERS; i++)
	{
		if (!IsPlayerConnected(i)) continue;
		if(Player[i][ADMIN] >= 1)
		{
			if(GetPVarInt(i, "SET_ADM_POS") == 0)
			{
				format(string, sizeof(string), "[%s #%d] %s[%d]", GSName[Player[i][ADMIN]], Player[i][ID], Player[i][pName], i);
			}
			if(GetPVarInt(i, "SET_ADM_POS") == 1)
			{
				format(string, sizeof(string), "[%s #%d] %s[%d] {2ec35a}(/sp > %d)", GSName[Player[i][ADMIN]], Player[i][ID], Player[i][pName], i, Player[i][Spectating][0]);
			}
			if(IsPlayerFlying(i) == 1 || IsPlayerFlying(i) == 2)
			{
				format(string, sizeof(string), "[%s #%d] %s[%d] {2ec35a}(/fly)", GSName[Player[i][ADMIN]], Player[i][ID], Player[i][pName], i);
			}
			if(GetPVarInt(i,"AFK_Check") == GetPVarInt(i,"AFK_Tick") && GetPlayerState(i))
			{
				format(string, sizeof(string), "[%s #%d] %s[%d] {FF6347}(AFK: %i ���)", GSName[Player[i][ADMIN]], Player[i][ID], Player[i][pName], i, GetPVarInt(i,"AFK_Time"));
			}
			SendClientMessage(playerid, 0xffd100FF, string);
		}
	}
	return true;
}

CMD:null(playerid, params[])
{
    if(Player[playerid][ADMIN] < 2) return 1;
    //if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� ��  ������ ��������� ��� � ����� �������� �������!");
    if(sscanf(params, "ds[26]", params[0])) return SCM(playerid, COLOR_GREY, "�����������: /null [id]");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
    
    
    new string[144];
    format(string, sizeof(string), "[%s #%d] %s[%d] ������� ������� %s[%d].", GSName[Player[playerid][ADMIN]], Player[playerid][ID], GN(playerid),playerid, gpname(params[0]), params[0]);
    SendAdminMessage(COLOR_WHITE, string);
    
    Player[params[0]][malinki] = 0;
    SetPlayerMoney(params[0], 0);
    
    new Query[128];
    format(Query, sizeof(Query), "UPDATE `Accounts` SET malinki = '0' WHERE id = '%i' LIMIT 1", Player[params[0]][ID]);
    mysql_tquery(ConnectMySQL, Query, "", "");
    return 1;
}

CMD:ban(playerid, params[])
{
    if(Player[playerid][ADMIN] < 4) return 1;
    if(sscanf(params, "is[144]", params[0], params[1])) return SCM(playerid, COLOR_GREY, "�������: /ban [ID ������] [�������]");
    if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� �� ������ ��������� ��� � ����� �������� �������!");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
    new string[144];
    format(string, sizeof(string), "������� ������ #%d ������������ ������� %s ��������. �������: %s", Player[playerid][ID], GN(params[0]), params[1]);
    SCMTA(COLOR_TOMATO, string);
    new Query[128];
    format(Query, sizeof(Query), "UPDATE `Accounts` SET ban = '1' WHERE name = '%s' LIMIT 1", Player[params[0]][pName]);
    mysql_tquery(ConnectMySQL, Query, "", "");
    TogglePlayerSpectating(params[0], 1);
    Kick(params[0]);
    return 1;
}

CMD:unban(playerid, params[])
{
    if(Player[playerid][ADMIN] < 3) return 1;
    //if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� ��  ������ ��������� ��� � ����� �������� �������!");
    if(sscanf(params, "s[24]", params[0])) return SCM(playerid, COLOR_GREY, "�������: /unban [��� ������]");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
    
   	new string[144];
	mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `name` = '%s' AND `ban` = '1'", params[0]);
 	return mysql_tquery(ConnectMySQL, string, "LoadUnBan", "d", playerid);
}

CMD:offban(playerid, params[])
{
    if(Player[playerid][ADMIN] < 4) return 1;
    //if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� ��  ������ ��������� ��� � ����� �������� �������!");
    if(sscanf(params, "s[24]", params[0])) return SCM(playerid, COLOR_GREY, "�������: /offban [��� ������]");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");

   	new string[144];
	mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `name` = '%s'", params[0]);
 	return mysql_tquery(ConnectMySQL, string, "LoadOffBan", "d", playerid);
}

CMD:offadmin(playerid, params[])
{
    if(Player[playerid][ADMIN] < 6) return 1;
    //if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� ��  ������ ��������� ��� � ����� �������� �������!");
    if(sscanf(params, "s[24]", params[0])) return SCM(playerid, COLOR_GREY, "�������: /offadmin [��� ������]");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");


   	new string[144];
	mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `name` = '%s'", params[0]);
 	return mysql_tquery(ConnectMySQL, string, "LoadOffAdmin", "d", playerid);
}

/*CMD:offmute(playerid, params[])
{
    if(Player[playerid][ADMIN] < 3) return 1;
    //if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� ��  ������ ��������� ��� � ����� �������� �������!");
    if(sscanf(params, "us[144]", params[0], params[1])) return SCM(playerid, COLOR_GREY, "�����������: /offmute [��� ������] [������]");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");

	SetPVarInt(playerid, "time_mute", params[1]*60);

   	new string[144];
	mysql_format(ConnectMySQL, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `name` = '%s'", params[0]);
 	return mysql_tquery(ConnectMySQL, string, "LoadOffMute", "d", playerid);
}*/

CMD:mute(playerid, params[])
{
    if(Player[playerid][ADMIN] < 2) return 1;
    if(sscanf(params, "dds[26]", params[0], params[1], params[2])) return SCM(playerid, COLOR_GREY, "�����������: /mute [id] [������] [�������]");
    if(GetPVarInt(params[0], "logged") == 0) return SCM(playerid, COLOR_GREY, "����� �� �����������");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
    new string[144];
    format(string, sizeof(string), "������� ������ #%d ������������ ��� %s �� %d ���. �������: %s", Player[playerid][ID], GN(params[0]), params[1], params[2]);
    SCMTA(COLOR_TOMATO, string);
    SCM(params[0], -1, "����� ������ ����� �� ����� ���������� ����, ������� \"/time\"");
    Player[params[0]][MUTE] = params[1]*60;
    MysqlUpdatePlayerInt(params[0], "mute", Player[params[0]][MUTE]);
    return 1;
}

CMD:vmute(playerid, params[])
{
    if(Player[playerid][ADMIN] < 2) return 1;
    if(sscanf(params, "dds[26]", params[0], params[1], params[2])) return SCM(playerid, COLOR_GREY, "�����������: /vmute [id] [������] [�������]");
    if(GetPVarInt(params[0], "logged") == 0) return SCM(playerid, COLOR_GREY, "����� �� �����������");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
    new string[144];
    format(string, sizeof(string), "������� ������ #%d ������������ ��������� ��� %s �� %d ���. �������: %s", Player[playerid][ID], GN(params[0]), params[1], params[2]);
    SCMTA(COLOR_TOMATO, string);
    SCM(params[0], -1, "����� ������ ����� �� ����� ���������� ���������� ����, ������� \"/time\"");
    Player[params[0]][VMUTE] = params[1]*60;
    SvMutePlayerEnable(params[0]);
    MysqlUpdatePlayerInt(params[0], "vmute", Player[params[0]][VMUTE]);
    return 1;
}

CMD:unvmute(playerid, params[])
{
    if(Player[playerid][ADMIN] < 2) return 1;
    if(sscanf(params, "ds[26]", params[0])) return SCM(playerid, COLOR_GREY, "�����������: /unvmute [id]");
    if(GetPVarInt(params[0], "logged") == 0) return SCM(playerid, COLOR_GREY, "����� �� �����������");
    if(GetPVarInt(playerid, "logged") == 0) return SCM(playerid, COLOR_GREY, "�� �� ������������");
    new string[144];
    format(string, sizeof(string), "������� ������ #%d ������������� ��������� ��� %s", Player[playerid][ID], GN(params[0]));
    SCMTA(COLOR_TOMATO, string);
    SCM(params[0], -1, "������� ������ ������������� ��� ��������� ���");
    Player[params[0]][VMUTE] = 0;
    SvMutePlayerDisable(params[0]);
    MysqlUpdatePlayerInt(params[0], "vmute", Player[params[0]][VMUTE]);
    return 1;
}

forward SecondUpdate();
public SecondUpdate()
{
    foreach(new i: Player)
    {
        if(Player[i][MUTE] != 0)
        {
            Player[i][MUTE]--;
            MysqlUpdatePlayerInt(i, "mute", Player[i][MUTE]);
        }
        if(Player[i][VMUTE] != 0)
        {
            Player[i][VMUTE]--;
            MysqlUpdatePlayerInt(i, "vmute", Player[i][VMUTE]);
        }
    }
}

forward CheckVoiceMutePlayer(playerid);
public CheckVoiceMutePlayer(playerid)
{
        if(Player[playerid][VMUTE] != 0) return true;
        SvMutePlayerDisable(playerid);
        return true;
}

CMD:unmute(playerid, params[])
{
    if(Player[playerid][ADMIN] < 2) return 1;
    if(sscanf(params, "ds[26]", params[0])) return SCM(playerid, COLOR_GREY, "�����������: /unmute [id]");
    if(GetPVarInt(params[0], "logged") == 0) return SCM(playerid, COLOR_GREY, "����� �� �����������");
    if(Player[params[0]][MUTE] == 0) return SCM(playerid, COLOR_GREY, "����� �� ����� ���������� ����");
    if(Player[params[0]][ADMIN] >= 6 && Player[playerid][ADMIN] != 7) return SCM(playerid, COLOR_GREY, "�� ��  ������ ��������� ��� � ����� �������� �������!");
    new string[144];
    format(string, sizeof(string), "������� ������ #%d ������������� ��� ������ %s.", Player[playerid][ID], GN(params[0]));
    SCMTA(COLOR_TOMATO, string);
    SCM(params[0], COLOR_WHITE, "�����������! ���������� ���� �����������. ������ �� ������ ������������ ����� ��� �����������");
    Player[params[0]][MUTE] = 0;
    MysqlUpdatePlayerInt(params[0], "mute", Player[params[0]][MUTE]);
    return 1;
}

CMD:fly(playerid)
{
    if(Player[playerid][ADMIN] < 1) return true;
    if(IsPlayerFlying(playerid) == 1) return SetPlayerFlyStatus(playerid, 0);
    
    SetPVarFloat(playerid, "SET_ADM_POS", 0);

    PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][0]);
    PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][1]);
    PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][2]);
    PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][3]);
    PlayerTextDrawHide(playerid, textinfo_TD_PTD[playerid][4]);

    Player[playerid][Spectating][0] = -1;
    KillTimer(UpdateSpecTimer[playerid]);
    
    SetPlayerFlyStatus(playerid, 2);
    return true;
}

CMD:flip(playerid, params[])
{
    if(Player[playerid][ADMIN] < 1) return 1;
    if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_GREY, "�����������: /flip [id]");
    if(GetPVarInt(playerid,"Counting_flip") > gettime() ) return SendClientMessage(playerid, COLOR_GREY, "������������ ��� ������� ����� ��� � 3 �������.");
    if(GetPVarInt(params[0], "logged") == 0) return SCM(playerid, COLOR_GREY, !"����� �� �����������!");
    if(GetPlayerState(params[0])!=2) return SCM(playerid, COLOR_GREY, "����� ������ �������� � ����������");
    new cpos = GetPlayerVehicleID(params[0]);
    new Float:X, Float:Y, Float:Z, Float:A;
    GetVehiclePos(cpos, X, Y, Z);
    SetVehiclePos(cpos,X, Y, Z);
    GetVehicleZAngle(cpos, A);
    SetVehicleZAngle(cpos, A);
    RepairVehicle(cpos);
    SetPVarInt(playerid,"Counting_flip",gettime() + 3);
    return 1;
}

CMD:payday(playerid)
{
    if(Player[playerid][ADMIN] < 6) return 1;
    PayDay();
    return 1;
}

CMD:hideme(playerid)
{
    if(Player[playerid][ADMIN] < 1) return 1;
    SendClientMessage(playerid, COLOR_GREY, "������������: /as");
    return 1;
}

// Anti - Cheat
static const AC_CODE_NAME[AC_MAX_CODES][AC_MAX_CODE_NAME_LENGTH] =
{
    "AirBreak ������",
    "AirBreak � ��",
    "�������� ������",
    "�������� � ��",
    "�������� ����� ��",
    "�������� � �� � ������",
    "�������� pickup",
    "FlyHack ������",
    "FlyHack � ��",
    "SpeedHack �����",
    "SpeedHack � ��",
    "Health hack � ��",
    "Health hack ������",
    "Armour hack",
    "Money hack",
    "Weapon hack",
    "Ammo hack ++",
    "Ammo hack �����������",
    "�������������� �����",
    "GodMode ������",
    "GodMode � ��",
    "Invisible",
    "Lagcomp-spoof",
    "������ �����",
    "������ ���",
    "������� �������",
    "������� �����",
    "Fake-Spawn",
    "Fake-Kill",
    "AimBot",
    "Run hack",
    "CarShot",
    "CarJack",
    "����������",
    "AFK �������",
    "Full Aiming",
    "Fake NPC",
    "���������������",
    "������� ����",
    "Dialog hack",
    "��������� hack",
    "����� ������ ������",
    "SR-Rcon hack",
    "Tuning crasher",
    "Invalid seat crasher",
    "Dialog crasher",
    "Attached object crasher",
    "Weapon Crasher",
    "Connects to one slot",
    "���� ����������� ���������",
    "���� ����� �����",
    "DDos",
    "NOP"
};

new AC_CODE_TRIGGER_TYPE[AC_MAX_CODES] =
{
    AC_CODE_TRIGGER_TYPE_KICK, // Airbreak (onfoot)
    AC_CODE_TRIGGER_TYPE_KICK, // Airbreak (in vehicle)
    AC_CODE_TRIGGER_TYPE_WARNING, // Teleport (onfoot)
    AC_CODE_TRIGGER_TYPE_WARNING, // Teleport (in vehicle)
    AC_CODE_TRIGGER_TYPE_WARNING, // Teleport (into/between vehicles)
    AC_CODE_TRIGGER_TYPE_WARNING, // Teleport (vehicle to player)
    AC_CODE_TRIGGER_TYPE_WARNING, // Teleport (pickups)
    AC_CODE_TRIGGER_TYPE_KICK, // FlyHack (onfoot)
    AC_CODE_TRIGGER_TYPE_WARNING, // FlyHack (in vehicle)
    AC_CODE_TRIGGER_TYPE_KICK, // SpeedHack (onfoot)
    AC_CODE_TRIGGER_TYPE_WARNING, // SpeedHack (in vehicle)
    AC_CODE_TRIGGER_TYPE_KICK, // Health hack (in vehicle)
    AC_CODE_TRIGGER_TYPE_KICK, // Health hack (onfoot)
    AC_CODE_TRIGGER_TYPE_KICK, // Armour hack
    AC_CODE_TRIGGER_TYPE_KICK, // Money hack
    AC_CODE_TRIGGER_TYPE_KICK, // Weapon hack
    AC_CODE_TRIGGER_TYPE_KICK, // Ammo hack (add)
    AC_CODE_TRIGGER_TYPE_KICK, // Ammo hack (infinite)
    AC_CODE_TRIGGER_TYPE_KICK, // Special actions hack
    AC_CODE_TRIGGER_TYPE_WARNING, // GodMode from bullets (onfoot)
    AC_CODE_TRIGGER_TYPE_WARNING, // GodMode from bullets (in vehicle)
    AC_CODE_TRIGGER_TYPE_KICK, // Invisible hack
    AC_CODE_TRIGGER_TYPE_KICK, // Lagcomp-spoof
    AC_CODE_TRIGGER_TYPE_KICK, // Tuning hack
    AC_CODE_TRIGGER_TYPE_WARNING, // Parkour mod
    AC_CODE_TRIGGER_TYPE_KICK, // Quick turn
    AC_CODE_TRIGGER_TYPE_KICK, // Rapid fire
    AC_CODE_TRIGGER_TYPE_KICK, // FakeSpawn
    AC_CODE_TRIGGER_TYPE_KICK, // FakeKill
    AC_CODE_TRIGGER_TYPE_WARNING, // Pro Aim
    AC_CODE_TRIGGER_TYPE_WARNING, // CJ run
    AC_CODE_TRIGGER_TYPE_WARNING, // CarShot
    AC_CODE_TRIGGER_TYPE_WARNING, // CarJack
    AC_CODE_TRIGGER_TYPE_KICK, // UnFreeze
    AC_CODE_TRIGGER_TYPE_WARNING, // AFK Ghost
    AC_CODE_TRIGGER_TYPE_WARNING, // Full Aiming
    AC_CODE_TRIGGER_TYPE_KICK, // Fake NPC
    AC_CODE_TRIGGER_TYPE_WARNING, // Reconnect
    AC_CODE_TRIGGER_TYPE_WARNING, // High Ping
    AC_CODE_TRIGGER_TYPE_KICK, // Dialog Hack
    AC_CODE_TRIGGER_TYPE_KICK, // Sandbox
    AC_CODE_TRIGGER_TYPE_KICK, // Invalid Version
    AC_CODE_TRIGGER_TYPE_KICK, // Rcon hack
    AC_CODE_TRIGGER_TYPE_KICK, // Tuning crasher
    AC_CODE_TRIGGER_TYPE_KICK, // Invalid seat crasher
    AC_CODE_TRIGGER_TYPE_KICK, // Dialog crasher
    AC_CODE_TRIGGER_TYPE_KICK, // Attached object crasher
    AC_CODE_TRIGGER_TYPE_KICK, // Weapon crasher
    AC_CODE_TRIGGER_TYPE_KICK, // Connects to one slot
    AC_CODE_TRIGGER_TYPE_KICK, // Flood callback functions
    AC_CODE_TRIGGER_TYPE_KICK, // Flood change seat
    AC_CODE_TRIGGER_TYPE_KICK, // DDos
    AC_CODE_TRIGGER_TYPE_KICK // NOP`s
};

forward OnCheatDetected(playerid, const ip_address[], type, code);
public OnCheatDetected(playerid, const ip_address[], type, code)
{
    if(Player[playerid][ADMIN] >= 1) return true;
    if(type == AC_GLOBAL_TRIGGER_TYPE_PLAYER)
    {
        new string[88 - 10 + MAX_PLAYER_NAME + 5 + AC_MAX_CODE_NAME_LENGTH + AC_MAX_CODE_LENGTH],
        trigger_type = AC_CODE_TRIGGER_TYPE[code];

        if(trigger_type == AC_CODE_TRIGGER_TYPE_WARNING)
        {
            format(string, sizeof(string), "[����-���] ���������� %s[%d] (#%d: %s)", gpname(playerid), playerid, code, AC_CODE_NAME[code]);
            SendAdminMessage(0xa0bbbbFF, string);
        }
        else // AC_CODE_TRIGGER_TYPE_KICK
        {
            format(string, sizeof(string), "[����-���] %s[%d] ������ (#%d: %s)", gpname(playerid), playerid, code, AC_CODE_NAME[code]);
            SendAdminMessage(0xa0bbbbFF, string);

            new str2[144];
            format(str2, sizeof(str2), "�� ���� ������� �� ���������� � ��������� (#%d)", code);
            SendClientMessage(playerid, COLOR_GREY, str2);

            TogglePlayerSpectating(playerid, true);
            AntiCheatKickWithDesync(playerid, code);
        }
    }
    return true;
}


