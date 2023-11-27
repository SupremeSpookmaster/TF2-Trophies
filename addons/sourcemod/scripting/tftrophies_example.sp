#define PLUGIN_NAME			  "TF2 Trophies Example Trophy Plugin"
#define PLUGIN_AUTHOR         "Spookmaster"
#define PLUGIN_DESCRIPTION    "An example of a Trophy plugin."
#define PLUGIN_VERSION        "1.0"
#define PLUGIN_URL            ""

//This is the name of our Trophy: King of Carnage. It tracks the damage dealt by all players throughout the round, and is awarded to the player who dealt the most damage.
#define TROPHY_DMG			"King of Carnage"

//This is how King of Carnage looks in data/tf2_trophies.cfg:
/*

"trophies"
{
	"King of Carnage"		//The name of this trophy.
	{
		"message"			"{orange}[TF2 Trophies] {crimson}King of Carnage{default} - Awarded to {green}%N{default} for {olive}dealing the most damage{default}."	//Message to print when this trophy is given out.
		"sound"				"misc/achievement_earned.wav"		//Sound to play when this trophy is awarded.
	}
}

*/

#include <sourcemod>
#include <sdktools>
#include <tftrophies>

#pragma semicolon 1

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

int DamageTracker[MAXPLAYERS+1] = {0, ...};

bool RoundActive = false;

public void OnPluginStart()
{
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_start", RoundStart);
	HookEvent("player_hurt", PlayerHurt);
}

public void RoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	RoundActive = true;
}

public void PlayerHurt(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	if (!RoundActive)
		return;
		
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	int amt = hEvent.GetInt("damageamount");
	
	if (attacker > 0 && attacker < MaxClients + 1 && IsClientInGame(attacker))
		DamageTracker[attacker] += amt;
}

public void OnClientDisconnect(int client)
{
	DamageTracker[client] = 0;
}

public void RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	RoundActive = false;
	RequestFrame(ResetDamageTracker);
}

public void ResetDamageTracker()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		DamageTracker[i] = 0;
	}
}

public Action TFTrophies_OnTrophyAwarded(char trophy[255], int &winner)
{
	if (StrEqual(trophy, TROPHY_DMG)) //First, let's make sure the Trophy System is currently processing our Trophy.
	{
		//Our Trophy is handed out to whomever deals the most damage during the round.
		//Let's cycle through all valid clients to find out who dealt the most damage.
		int client = 0;
		int biggest = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (DamageTracker[i] > biggest)
			{
				client = i;
				biggest = DamageTracker[i];
			}
		}
		
		if (client > 0 && client < MaxClients + 1 && IsClientInGame(client) && biggest > 0)
		{
			//Our Trophy has an option to play a custom sound to the winner, which can be configured in data/tf2_trophies.cfg.
			//Here, we will retrieve that sound, make sure it exists, and play it to the winner.
			char snd[255], checkPath[255];
			TFTrophies_GetArgS(trophy, "sound", snd);
			
			Format(checkPath, PLATFORM_MAX_PATH, "sound/%s", snd);
			
			bool exists = false;
			if (FileExists(checkPath))
			{
				exists = true;
			}
			else
			{
				if (FileExists(checkPath, true))
				{
					exists = true;
				}
			}
	
			if (exists)
			{
				PrecacheSound(snd);
				EmitSoundToClient(client, snd, _, _, 120);
			}
			
			//Set "winner" to the client index of the player who dealt the most damage and return Plugin_Changed.
			winner = client;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}
