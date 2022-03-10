#include <sdktools>
#include <multicolors>
#include <cstrike>
#include <multi1v1>

#pragma semicolon 1
#pragma newdecls required
#define TAG_COLOR	"{green}[PTR-Dev]{default}"
//#define DEBUG

int menuSelected[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[CS:GO] Arenas Finder",
	author = "Trayz",
	description = "",
	version = "1.0",
	url = "ptrunners.net"
};

public void OnPluginStart()
{
	#if defined DEBUG
	RegAdminCmd("sm_debugarenas", Command_DebugArenas, ADMFLAG_ROOT);
	#endif

	RegAdminCmd("sm_spawnarenas", Command_SpawnArenas, ADMFLAG_ROOT);
	
	HookEvent("round_start", EventRoundStart, EventHookMode_PostNoCopy);
}

public void EventRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		OnClientDisconnect(client);
	}
}

public void OnClientDisconnect(int client)
{
	menuSelected[client] = -1;
}

public Action Command_DebugArenas(int client, int args)
{
	int maxArenas = Multi1v1_GetMaximumArenas();

	PrintToChat(client, "maxArenas: %i", maxArenas);

	for(int i = 1; i <= maxArenas; i++)
	{
		float origin[3];
		float angle[3];

		Multi1v1_GetArenaSpawn(i, CS_TEAM_T, origin, angle);

		PrintToChat(client, "Arena %i: Origin: %f | Angle: %f", i, origin, angle);
	}

	return Plugin_Handled;
}

public Action Command_SpawnArenas(int client, int args)
{
	if(!client) return Plugin_Handled;

	MenuSpawn(client);
	return Plugin_Handled;
}

void MenuSpawn(int client)
{
	Menu menu = new Menu(MenuHandler_Spawn, MenuAction_Select|MenuAction_Cancel|MenuAction_End|MenuAction_DrawItem);
	menu.SetTitle("[Arenas Spawn T]");
	char menu_text[32];
	char arena_id[4];

	int maxArenas = Multi1v1_GetMaximumArenas();

	for(int i = 1; i <= maxArenas; i++)
	{
		FormatEx(menu_text, sizeof(menu_text), "Arena %d", i);
		FormatEx(arena_id, sizeof(arena_id), "%d", i);
		menu.AddItem(arena_id, menu_text);
	}

	if(menu.ItemCount > 7)
	{
		menu.ExitBackButton = true;
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Spawn(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Cancel:
		{
			menuSelected[param1] = -1;
		}
		case MenuAction_End:
		{
			if(param1 != MenuEnd_Selected)
			{
				menuSelected[param1] = -1;
				delete(menu);
			}
		}
		case MenuAction_Select:
		{
			char option[32];
			menu.GetItem(param2, option, sizeof(option));
			menuSelected[param1] = param2;
			int target = StringToInt(option);
			if(target <= 0)
			{
				CPrintToChat(param1, "%s {darkred}An error occured.", TAG_COLOR);
				return 0;
			}
			else
			{
				GoToEntity(param1, target);
			}
			menu.DisplayAt(param1, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
			return 0;
		}
		case MenuAction_DrawItem:
		{
			int style;
			char option[32];
			menu.GetItem(param2, option, sizeof(option), style);
			
			if(menuSelected[param1] == param2)
			{
				return ITEMDRAW_DISABLED;
			}

			return style;
		}
	}
	return 0;
}

stock void GoToEntity(int client, int arena)
{
	float origin[3];
	float angle[3];
	Multi1v1_GetArenaSpawn(arena, CS_TEAM_T, origin, angle);

	TeleportEntity(client, origin, angle, NULL_VECTOR);
	CPrintToChat(client, "%s {lightblue}You have been brought to arena %d.", TAG_COLOR, arena);
	return;
}