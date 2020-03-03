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

public void OnConfigsExecuted()
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

	if (!kv.JumpToKey("Maps"))
	{
		delete kv;
		LogError("The configuration file is corrupt (\"Maps\" section could not be found).");
		return;
	}

	char currentMap[PLATFORM_MAX_PATH], map[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));

	if (kv.GotoFirstSubKey(false))
	{
		do
		{
			if (!kv.GetSectionName(map, sizeof(map)))
			{
				continue;
			}

			if (StrEqual(map, currentMap, false))
			{
				continue;
			}
			
			DeleteMapFiles(map);

		} while (kv.GotoNextKey(false));
	}
	
	delete kv;
}

void DeleteMapFiles(const char[] map)
{
	char file[PLATFORM_MAX_PATH];		
	
	Format(file, sizeof(file), "%s.bsp", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}
	
	Format(file, sizeof(file), "%s.nav", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}
	
	Format(file, sizeof(file), "%s.jpg", map);
	if (FileExists(file))
	{
		DeleteFile(file);
	}
}
