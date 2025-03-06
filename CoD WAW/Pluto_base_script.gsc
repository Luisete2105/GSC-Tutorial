#include maps\_utility;
#include common_scripts\utility;

main()
{
}

init()
{
    level thread onplayerconnect();
}

onplayerconnect()
{
    level endon( "game_ended" );

    for (;;)
	{
        level waittill( "connected", player ); 
        player thread onplayerspawned();

	}
}

onplayerspawned()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
	{
        self waittill( "spawned_player" );
    }
}