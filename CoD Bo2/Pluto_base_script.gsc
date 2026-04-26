#include maps\_utility;
#include common_scripts\utility;

// Entry point
main()
{
}

// Entry point
init()
{
    level thread onplayerconnect();
}

// Called whenever a player connects
onplayerconnect()
{
    level endon( "game_ended" );

    for (;;)
	{
        level waittill( "connected", player ); 
        player thread onplayerspawned();
	}
}

// Called whenever a player spawns
onplayerspawned()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
	{
        self waittill( "spawned_player" );
    }
}