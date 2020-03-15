#include <sourcemod>
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Delete Files",
	author = "Ilusion9",
	description = "Delete files from server.",
	version = "1.1",
	url = "https://github.com/Ilusion9/"
};

public void OnMapStart()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/delete_files.cfg");

	KeyValues kv = new KeyValues("Delete Files");
	if (!kv.ImportFromFile(path))
	{
		delete kv;
		LogError("The configuration file could not be read.");
		return;
	}

	if (!kv.JumpToKey("Configs"))
	{
		delete kv;
		LogError("The configuration file is corrupt (\"Configs\" section could not be found).");
		return;
	}

	char buffer[PLATFORM_MAX_PATH];
	if (kv.GotoFirstSubKey(false))
	{
		do
		{
			if (!kv.GetSectionName(buffer, sizeof(buffer)))
			{
				continue;
			}

			DeleteConfigFiles(buffer);

		} while (kv.GotoNextKey(false));
	}

	kv.Rewind();
	if (!kv.JumpToKey("Maps"))
	{
		delete kv;
		LogError("The configuration file is corrupt (\"Maps\" section could not be found).");
		return;
	}

	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));

	if (kv.GotoFirstSubKey(false))
	{
		do
		{
			if (!kv.GetSectionName(buffer, sizeof(buffer)))
			{
				continue;
			}
			
			DeleteMapFiles(buffer);

		} while (kv.GotoNextKey(false));
	}
	
	delete kv;
}

void DeleteConfigFiles(char[] config)
{
	char file[PLATFORM_MAX_PATH];		
	Format(file, sizeof(file), "cfg/%s.cfg", config);

	if (FileExists(file))
	{
		DeleteFile(file);
	}
}

void DeleteMapFiles(char[] mapName)
{
	bool hasWildcard;
	int mapLen = strlen(mapName), extPos;
	char currentMap[PLATFORM_MAX_PATH], buffer[PLATFORM_MAX_PATH], fileName[PLATFORM_MAX_PATH];	
	
	FileType type;
	DirectoryListing dir = OpenDirectory("maps");
	GetCurrentMap(currentMap, sizeof(currentMap));
	
	if (mapName[mapLen - 1] == '*')
	{
		hasWildcard = true;
		mapName[--mapLen] = 0;
	}
	
	while (dir.GetNext(buffer, sizeof(buffer), type))
	{
		if (type != FileType_File)
		{
			continue;
		}
		
		// Get file name without extension
		strcopy(fileName, sizeof(fileName), buffer);
		extPos = FindCharInString(buffer, '.', true);
		
		if (extPos != -1)
		{
			fileName[extPos] = 0;
		}
		
		// Check if the file belongs to the map we are looking for to delete
		if (hasWildcard)
		{
			if (!StrNumEqual(fileName, mapName, mapLen, false))
			{
				continue;
			}
		}
		else
		{
			if (!StrEqual(fileName, mapName, true))
			{
				continue;
			}
		}
		
		// Check if the file doesn't belong to the current map
		if (StrEqual(fileName, currentMap, false))
		{
			continue;
		}
		
		Format(buffer, sizeof(buffer), "maps/%s", buffer);
		DeleteFile(buffer);
	}
	
	delete dir;
}

bool StrNumEqual(const char[] str1, const char[] str2, int num, bool caseSensitive)
{
	return strncmp(str1, str2, num, caseSensitive) == 0;
}
