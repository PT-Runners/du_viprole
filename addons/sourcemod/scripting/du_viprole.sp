#include <sourcemod>
#include <multicolors>
#include <discord_utilities>

ConVar cv_sDiscordRoleId;
ConVar cv_sFlag;

char sRoleId[60];
char sFlag[5];

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
	cv_sDiscordRoleId.GetString(sRoleId, sizeof(sRoleId));

	AutoExecConfig();
}

public void DU_OnAccountRevoked(int client, const char[] userid)
{
	if(DU_CheckRole(client, sRoleId))
	{
		DU_DeleteRole(client, sRoleId);
	}
}

public void DU_OnClientLoaded(int client)
{
	if(!DU_IsMember(client))
	{
		return;
	}
	
	if(!CheckAdminFlag(client, sFlag))
	{
		if(DU_CheckRole(client, sRoleId))
		{
			DU_DeleteRole(client, sRoleId);
		}

		return;
	}

	DU_AddRole(client, sRoleId);
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
