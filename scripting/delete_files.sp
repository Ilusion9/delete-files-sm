#include <sourcemod>
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Delete Files",
	author = "Ilusion9",
	description = "Delete files from server.",
	version = "1.0",
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

			DeleteConfig(buffer);

		} while (kv.GotoNextKey(false));
	}

	kv.Rewind();
	if (!kv.JumpToKey("Maps"))
	{
		delete kv;
		LogError("The configuration file is corrupt (\"Maps\" section could not be found).");
		return;
	}

	int length;
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
			
			length = strlen(buffer);
			if (buffer[--length] == '*')
			{
				buffer[length] = '\0';
				DeleteMapsByPattern(buffer, length, currentMap);
			}
			else
			{
				DeleteMap(buffer, currentMap);
			}

		} while (kv.GotoNextKey(false));
	}
	
	delete kv;
}

void DeleteConfig(const char[] cfg)
{
	char file[PLATFORM_MAX_PATH];		
	Format(file, sizeof(file), "cfg/%s.cfg", cfg);

	if (FileExists(file))
	{
		DeleteFile(file);
	}
}

void DeleteMapsByPattern(const char[] pattern, int patternLen, const char[] currentMap)
{
	int pos;
	char buffer[PLATFORM_MAX_PATH];
	
	FileType type;
	DirectoryListing dir = OpenDirectory("maps");

	while (dir.GetNext(buffer, sizeof(buffer), type))
	{
		if (type != FileType_File)
		{
			continue;
		}
		
		// Check if the file has the pattern we are looking for
		if (!strnequal(buffer, pattern, patternLen, false))
		{
			continue;
		}
		
		// Check if the file belongs to the current map on the server
		// The extension of the file will be ignored
		pos = FindCharInString(buffer, '.', true);
		if (pos == -1 || strnequal(buffer, currentMap, pos, true))
		{
			continue;
		}
		
		Format(buffer, sizeof(buffer), "maps/%s", buffer);
		DeleteFile(buffer);
	}
	
	delete dir;
}

void DeleteMap(const char[] map, const char[] currentMap)
{
	// Check if the map files we are looking for belongs to the current map on the server
	if (StrEqual(map, currentMap, false))
	{
		return;
	}
	
	int pos;
	char buffer[PLATFORM_MAX_PATH];
	
	FileType type;
	DirectoryListing dir = OpenDirectory("maps");

	while (dir.GetNext(buffer, sizeof(buffer), type))
	{
		if (type != FileType_File)
		{
			continue;
		}
		
		// Check if the file belogns to the map we are looking for to delete
		// The extension of the file will be ignored
		pos = FindCharInString(buffer, '.', true);
		if (pos == -1 || !strnequal(buffer, map, pos, true))
		{
			continue;
		}
		
		Format(buffer, sizeof(buffer), "maps/%s", buffer);
		DeleteFile(buffer);
	}
	
	delete dir;
}

bool strnequal(const char[] str1, const char[] str2, int num, bool caseSensitive)
{
	return strncmp(str1, str2, num, caseSensitive) == 0;
}
