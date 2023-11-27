#define PLUGIN_NAME           		  "[TF2] Trophy System"

#define PLUGIN_AUTHOR         "Spookmaster"
#define PLUGIN_DESCRIPTION    "Hands out trophies in chat at the end of each round, as a reward for certain actions. Allows devs to easily make custom trophies as well."
#define PLUGIN_VERSION        "1.0.0"
#define PLUGIN_URL            "https://github.com/SupremeSpookmaster/TF2-Trophies"

#pragma semicolon 1

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

#include <sourcemod>
#include <tf2_stocks>
#include <tftrophies>
#include <cfgmap>
#include <morecolors>
#include <textstore>

GlobalForward g_OnAwarded;

ConfigMap g_TrophiesList;

public void OnPluginStart()
{
	CreateTrophiesList();
	
	g_OnAwarded = new GlobalForward("TFTrophies_OnTrophyAwarded", ET_Event, Param_String, Param_CellByRef);
	
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_stalemate", RoundEnd);
}

public void CreateTrophiesList()
{
	if (g_TrophiesList != null)
		DeleteCfg(g_TrophiesList);
		
	g_TrophiesList = new ConfigMap("data/tf2_trophies.cfg");
	
	if (g_TrophiesList == null)
	{
		SetFailState("data/tf2_trophies.cfg does not exist. Aborting trophy awards.");
		return;
	}
}

public void OnMapStart()
{
	RegPluginLibrary("tf2_trophies");
	
	CreateNative("TFTrophies_GetArgI", Native_TFTrophies_GetArgI);
	CreateNative("TFTrophies_GetArgF", Native_TFTrophies_GetArgF);
	CreateNative("TFTrophies_GetArgS", Native_TFTrophies_GetArgS);
}

public void RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	ConfigMap trophies = g_TrophiesList.GetSection("trophies");
	StringMapSnapshot snap = trophies.Snapshot();
	
	for (int i = 0; i < snap.Length; i++)
	{
		char key[255], message[255];
		snap.GetKey(i, key, sizeof(key));
		
		int winner = 0;
		Action result;
		
		Call_StartForward(g_OnAwarded);
		
		Call_PushString(key);
		Call_PushCellRef(winner);
		
		Call_Finish(result);
		
		if (result != Plugin_Handled && result != Plugin_Stop && (winner > 0 && winner < MaxClients + 1 && IsClientInGame(winner)))
		{
			ConfigMap subsection = g_TrophiesList.GetSection(key);
		
			subsection.Get("message", message, sizeof(message));
			
			CPrintToChatAll(message, winner);
		}
	}
	
	delete snap;
	
	CreateTrophiesList();
}

public Native_TFTrophies_GetArgI(Handle plugin, int numParams)
{
	char trophy[255], arg[255];
	GetNativeString(1, trophy, 255);
	GetNativeString(2, arg, 255);
	int def = GetNativeCell(3);
	
	char val[255], path[255];
	Format(path, sizeof(path), "trophies.%s.%s", trophy, arg);
	g_TrophiesList.Get(path, val, sizeof(val));
	
	return StrEqual(val, "") ? def : StringToInt(val);
}

public any Native_TFTrophies_GetArgF(Handle plugin, int numParams)
{
	char trophy[255], arg[255];
	GetNativeString(1, trophy, 255);
	GetNativeString(2, arg, 255);
	float def = GetNativeCell(3);
	
	char val[255], path[255];
	Format(path, sizeof(path), "trophies.%s.%s", trophy, arg);
	g_TrophiesList.Get(path, val, sizeof(val));
	
	return StrEqual(val, "") ? def : StringToFloat(val);
}

public Native_TFTrophies_GetArgS(Handle plugin, int numParams)
{
	char trophy[255], arg[255];
	GetNativeString(1, trophy, 255);
	GetNativeString(2, arg, 255);
	int size = GetNativeCell(4);
	
	char val[255], path[255];
	Format(path, sizeof(path), "trophies.%s.%s", trophy, arg);
	g_TrophiesList.Get(path, val, sizeof(val));
	
	SetNativeString(3, val, size);
}