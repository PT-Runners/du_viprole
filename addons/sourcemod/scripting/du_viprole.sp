#include <sourcemod>
#include <multicolors>
#include <tVip>
#include <discord_utilities>

ConVar cv_sDiscordRoleId;
ConVar cv_sFlag;
ConVar cv_Time;

char sRoleId[60];
char sFlag[5];

bool duClientLoaded[MAXPLAYERS + 1] = {false, ...};
bool tVipLoaded[MAXPLAYERS + 1] = {false, ...};

public Plugin myinfo = 
{
	name = "Discord Utilities: VIP Role",
	author = "Trayz",
	description = "Give credits to users that are verified!",
	version = "1.0",
	url = "ptrunners.net"
};

public void OnPluginStart()
{
	cv_sFlag = CreateConVar("sm_du_viprole_flag", "o", "Flag server.");
	cv_sFlag.GetString(sFlag, sizeof(sFlag));

	cv_sDiscordRoleId = CreateConVar("sm_du_viprole_id", "909788852959473664", "Role ID Discord.");
	cv_Time = CreateConVar("sm_du_viprole_time", "120.0");
	cv_sDiscordRoleId.GetString(sRoleId, sizeof(sRoleId));

	AutoExecConfig();

	CreateTimer(GetConVarFloat(cv_Time), Timer_VipRole, _, TIMER_REPEAT);
}

public Action Timer_VipRole(Handle hTimer)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i) || IsFakeClient(i))
		{
			continue;
		}

		if(!duClientLoaded[i])
		{
			continue;
		}

		if(!tVipLoaded[i])
		{
			continue;
		}

		if(!DU_IsChecked(i))
		{
			continue;
		}

		if(!DU_IsMember(i))
		{
			continue;
		}

		if(!CheckAdminFlag(i, sFlag))
		{
			DU_DeleteRole(i, sRoleId);
			continue;
		}
		
		DU_AddRole(i, sRoleId);
	}
}

public void tVip_OnClientLoadedPost(int client)
{
	tVipLoaded[client] = true;
}

public void DU_OnClientLoaded(int client)
{
	duClientLoaded[client] = true;
}

stock bool CheckAdminFlag(int client, const char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}
	
	return bEntitled;
}

stock bool IsValidClient(int client)
{
    return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}