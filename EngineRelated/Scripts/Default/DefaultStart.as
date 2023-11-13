// default startup functions for autostart scripts

void RunServer()
{
	//print("\n NIGGER \n");
	if (getNet().CreateServer())
	{
		//print("\n NIGGER \n");
		LoadRules("Rules/" + sv_gamemode + "/gamemode.cfg");
		//print("\n NIGGER \n");
		
		//getRules().set_bool("it_is_localhost_my_dudes_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", true);
		//print("check: "+getRules().get_bool("it_is_localhost_my_dudes_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));

		if (sv_mapcycle.size() > 0)
		{
			LoadMapCycle(sv_mapcycle);
		}
		else
		{
			LoadMapCycle("Rules/" + sv_gamemode + "/mapcycle.cfg");
		}

		LoadNextMap();
	}
}

void ConnectLocalhost()
{
	//print("\n NIGGER 2 \n");
	getNet().Connect("localhost", sv_port);
}

void RunLocalhost()
{
	//print("\n NIGGER 3 \n");
	RunServer();
	ConnectLocalhost();
}

void LoadDefaultMenuMusic()
{
	//print("\n NIGGER 4 \n");
	if (s_menumusic)
	{
		CMixer@ mixer = getMixer();
		if (mixer !is null)
		{
			mixer.ResetMixer();
			mixer.AddTrack("Sounds/Music/world_intro.ogg", 0);
			mixer.PlayRandom(0);
		}
	}
}
