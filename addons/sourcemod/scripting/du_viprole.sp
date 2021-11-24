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

	LoadTranslations("du_viprole.phrases");

	AutoExecConfig();
}

public void DU_OnClientLoaded(int client)
{
	if(!CheckAdminFlag(client, sFlag))
	{
		DU_DeleteRole(client, sRoleId);
		return;
	}

	if(!DU_IsMember(client))
	{
		return;
	}
	
	DU_AddRole(client, sRoleId);

	CreateTimer(15.0, PrintToVip, GetClientSerial(client)); // You could also use GetClientUserId(client)
}

public Action PrintToVip(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial); // Validate the client serial
 
    if (client == 0) // The serial is no longer valid, the player must have disconnected
    {
        return Plugin_Stop;
    }
 
    CPrintToChat(client, "%t", "Added vip role");
 
    return Plugin_Continue;
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
