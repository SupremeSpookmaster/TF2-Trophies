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

GlobalForward g_OnAwarded;

ConfigMap g_TrophiesList;

#define SND_ADMINCOMMAND		"ui/cyoa_ping_in_progress.wav"

public void OnPluginStart()
{
	CreateTrophiesList();
	
	g_OnAwarded = new GlobalForward("TFTrophies_OnTrophyAwarded", ET_Event, Param_String, Param_CellByRef);
	
	RegAdminCmd("givetrophies", GiveThemOut, ADMFLAG_KICK, "TF2 Trophies: Immediately hands out trophies to clients who have earned them.");
	
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_stalemate", RoundEnd);
}

public void OnMapStart()
{
	PrecacheSound(SND_ADMINCOMMAND);
}

public Action GiveThemOut(int client, int args)
{	
	if (client > 0 && client < MaxClients + 1 && IsClientInGame(client))
	{
		CPrintToChat(client, "{orange}[TF2 Trophies] {default}Initiating trophy delivery.");
		EmitSoundToClient(client, SND_ADMINCOMMAND);
	}	
	
	GiveTrophies();
	
	return Plugin_Continue;
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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("tf2_trophies");
	
	CreateNative("TFTrophies_GetArgI", Native_TFTrophies_GetArgI);
	CreateNative("TFTrophies_GetArgF", Native_TFTrophies_GetArgF);
	CreateNative("TFTrophies_GetArgS", Native_TFTrophies_GetArgS);
	CreateNative("TFTrophies_GiveTrophies", Native_TFTrophies_GiveTrophies);
	
	return APLRes_Success;
}

public void RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	GiveTrophies();
}

public void GiveTrophies()
{
	ConfigMap trophies = g_TrophiesList.GetSection("trophies");
	StringMapSnapshot snap = trophies.Snapshot();
	
	for (int i = snap.Length - 1; i > -1; i--)
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
			ConfigMap subsection = trophies.GetSection(key);
		
			subsection.Get("message", message, sizeof(message));
			
			DataPack pack = new DataPack();
			CreateDataTimer(0.5, Timer_GiveTrophy, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, GetClientUserId(winner));
			WritePackString(pack, message);
		}
	}
	
	delete snap;
	
	CreateTrophiesList();
}

public Action Timer_GiveTrophy(Handle giveit, DataPack pack)
{
	ResetPack(pack);
	int winner = GetClientOfUserId(ReadPackCell(pack));
	char message[255];
	ReadPackString(pack, message, 255);
	
	if (winner > 0 && winner < MaxClients + 1 && IsClientInGame(winner))
		CPrintToChatAll(message, winner);
		
	return Plugin_Continue;
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
	int size = 255;
	
	char val[255], path[255];
	Format(path, sizeof(path), "trophies.%s.%s", trophy, arg);
	g_TrophiesList.Get(path, val, sizeof(val));
	
	SetNativeString(3, val, size);
}

public Native_TFTrophies_GiveTrophies(Handle plugin, int numParams)
{
	GiveTrophies();
}