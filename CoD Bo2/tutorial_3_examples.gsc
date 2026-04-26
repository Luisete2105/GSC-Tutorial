/* GSC TUTO

    1º) Macro and defines
        - How to create one.
        - How to use it.

    2º) HUDs
        - How to make a HuD element.
        - How to display a value (Timer, Number, Letters).
        - How to use a label (IString).
        - How to display a shader (Credits to CabCon for the shader list! (https://pastebin.com/raw/K7u6AL11).

    3º) Overflow problem
        - How to fix manually ( Hud clearalltextafterhudelem() ).
        - How to fix with Serious' overflow fix file ( Original Serious overflow fix https://github.com/seriousyt/iw-gsc-util/blob/master/serious-gsc.gsc ).

    4º) Extra tips
        -How 3arc creates HUDs
        -How to show an specific button bind for a player

*/


//#include maps\_utility;
#include common_scripts\utility;

// Adding serious overflow fix
#include scripts\zm\serious_overflow_fix;

/* Macros

    *What's a macro?
        -Macros are code snippets that are placed before script compilation.

    *Common uses:
        -Defining a constant value.
        -Defining a value that we want to test and we want to change on multiple places of the script for testing purposes.
        -Automating a repetitive code.
        -Giving a more understandable name to a value or code snippet.
        -Once a macro is defined, it can be used on other macros.
*/

// Constant values
#define TRANZIT     "zm_transit"
#define DIE_RISE    "zm_highrise"
#define BURIED      "zm_buried"

// Values I want to change and test
#define HUD_GLOBAL_X       10
#define HUD_GLOBAL_Y       0
#define HUD_PLAYER_X       -10
#define HUD_PLAYER_Y       30

// Macros
#define MAP_NAME tolower( getdvar( "mapname" ) )        // Example of macro without parameters
#define IS_TRUE( _arg ) ( isdefined( _arg ) && _arg )   // Example of macro with parameters

// Wait
#define SERVER_FRAME .05
#define WAIT_SERVER_FRAME {wait(SERVER_FRAME);} // A macro can use a previously defined macro!

// Stop zombie scripts from running on main menu
#define STOP_IF_MAIN_MENU if ( MAP_NAME == "frontend" ) return;


// Entry point
main()
{
    // Dont execute the script if we are on the menu
    STOP_IF_MAIN_MENU

    // Watch for players spawning
    level thread onplayerconnect();


    // Serious overflow fix
    level thread SOverflowMonitor();

    level._x = HUD_GLOBAL_X;
    level._y = HUD_GLOBAL_Y;

    level.shader_names = array( "button_left_mouse", "xenonbutton_dpad_left", "xenonbutton_a", "button_right_mouse" );

    // Precache shaders
    for( i=0; i<level.shader_names.size; i++){
        precacheshader( level.shader_names[ i ] );
    }

}

// Entry point
init()
{
    // Dont execute the script if we are on the menu
    STOP_IF_MAIN_MENU

    // Print the default values of a new HuD
    //level thread print_default_hud_keys();

    // Show Timer count up example
    //b_show_tenths = true;
    //level thread set_start_timer( b_show_tenths );

    // Show Timer count down example
    //b_show_tenths = true;
    //time = 7;
    //level thread set_countdown_timer( b_show_tenths, time );

    // Show Value example
    //level thread set_zombie_counter();

    // Show Text example
    //level thread set_host_name();

    // Show shaders
    //level thread show_shaders();

    // Show full screen shader
    // level thread show_fullscreen_shader();

    // Show colors on shaders
    //color = (0x77/0xFF, 0x77/0xFF, 0x77/0xFF);
    //level thread show_shader_color( color );
}

// Called whenever a player connects
onplayerconnect()
{
    level endon( "game_ended" );

    for (;;)
	{
        level waittill( "connected", player ); 
        player thread on_player_connect();
	}
}

// Called whenever a player spawns
on_player_connect(){

    // Show how many different strings you can set to HUDs before getting error
    //self thread overflow_fix_test();

    // Waypoint to the closest zombie
    //self thread waypoint_zombie();

    // Show which keys is being pressed by the player
    //self thread check_all_player_buttons();
}

/* How to make a HuD element

    HuD elements are created by the game with an engine function, you have to choose which one you want or need to use.
    There is a limit for the amount of HUDs that can be created at the same time which is around 40, however, you can get extra ones
    if you set the .archived value to true on the last ~10 ones.
    
    *For everyone:
        hud = newHudElem();

    *For a specific team:
        hud = newteamhudelem( team );

    *For a specific player:
        hud = newclienthudelem( player );

    *When you are no longer going to use a HuD, you must call the method "destroy()", it will send a "death" notify to the HuD.
        -HuD destroy();

    You can customize HuD elements by changing the data on their structs which are the following with their default values

        hud.x = 0
        hud.y = 0
        hud.z = 0
        hud.fontscale = 1
        hud.font = "default"
        hud.alignx = "left"
        hud.aligny = "top"
        hud.horzalign = "subleft"
        hud.vertalign "subtop"
        hud.color = (1,1,1)
        hud.alpha = 1
        hud.label = ""
        hud.sort = 0
        hud.foreground = 0
        hud.hidewhendead = 0
        hud.hidewheninkillcam = 0
        hud.hidewhenindemo = 0
        hud.immunetodemogamehudsettings = 0
        hud.immunetodemofreecamera = 0
        hud.hidewhileremotecontrolling = 0
        hud.hidewheninmenu = 0
        hud.hidewheninscope = 0
        hud.fadewhentargeted = 0
        hud.fontstyle3d = "normal" // Either "normal" or "shadowedmore";
        hud.font3duseglowcolor = 0
        hud.glowcolor = (0,0,0)
        hud.glowalpha = 0
        hud.archived = 1
        hud.showplayerteamhudelemtospectator = 0

    You can set any value just by accessing the struct key from the HuD with the exception of .label on Bo2 and newer games.
    Older CoDs just use a regular string as a label but since Bo2, you have to make it an istring.
    To indicate a string is an istring you have 2 options:
        1) Add & before the string literal. Example -> hud.label = &"Siuuuuu";
        2) use istring( text ) function. Example -> hud.label = istring( player.name );

    You can only display 1 type of data on the HuD:

        Timers:
            // Countdown
            Hud settimer( time );
            Hud settenthstimerup( time ); // You can NOT set 0 on the timer otherwise it will glitch and wont do anything

            // Count
            Hud settimerup( time ); // To set the time to start from a value greater than 0, you have to make it a negative number! for example: HuD SetTimerUp( 0 - time );
            Hud settenthstimerup( time );  // You can NOT set 0 on the timer otherwise it will glitch and wont do anything

        Number:
            Hud SetValue( number );

        Text:
            Hud SetText( message ); // You can change the color like we do on prints, check Tutorial #2 video or its code on the link https://github.com/Luisete2105/GSC-Tutorial/blob/3110e7b873be8db26d8d658834caeaabf54d2cd5/CoD%20Bo1/Tutorial_2_examples.gsc#L449
            
            You can set a decoding effect on a text!
            hud_element SetCOD7DecodeFX(<decodeTime>,<decayStart>,<decayDuration>);
        
        Shader:
            HuD setshader( str_shader, n_width, n_height );

    Only .label needs to be an istring, messages displayed with SetText( message ) do not need to be converted to istring.

    BE CAREFUL WHEN DISPLAYING A TEXT!
    Whenever a label or text is set on a HuD, it's added to a config string list, whenever it gets above the game's limit you will either get a crash or get kicked from the game.
    To avoid this error you must use -> Hud clearalltextafterhudelem();
    However it will only clear the texts that were registered after that specific text including the current text. For more information check serious video ( https://www.youtube.com/watch?v=pGAw8QLT5V8 )

    A way to avoid it is by using SetValue whenever its possible. For example if you want to create a zombie counter it will be like this:

        - SetText( "Zombies: "+getaiarray( "axis" ).size )
        - .label = &"";
            When there is 0 zombies we will get "Zombies: 0"
            When there is 1 zombie we will get "Zombies: 1"
            When there are 2 zombies we will get "Zombies: 2"
            ... etc
            We would get 1 config string for each possible value whenever its reached.
        
        -SetValue( getaiarray( "axis" ).size );
        - .label = &"Zombies: ";
            This way we only create 1 config string that will be used for every value because we are using SetValue to display the number of zombies.
            Label is not changing therefore we are not creating additional config strings.

    *Transition methods:
        -HuD fadeovertime( time )
            after this method is called, you must change hud.alpha OR hud.color to the desired target.
        -HuD moveovertime( time )
            after this method is called, you must change hud.x or hud.y or both to the desired target.
        -HuD changefontscaleovertime( time );
            after this method is called, you must change hud.fontscale to the desired target.
        -HuD scaleovertime( time, width, height ) // Changes the sizes of the shader in the specified time
            No need to change a HuD value after this method because they are already set as parameters

    If you want to make a HuD 3D, you have to make it a waypoint and it has some special attributes
    *Waypoints:
        -HuD setwaypoint( b_constant_size, shader ); // Converts HuD to a waypoint
        -HuD settargetent( e_entity ); // Makes the HuD to be fixed to the entity
        -HuD cleartargetent(); // Detaches the HuD from the targeted entity
        -HuD scaleovertime( time, width, height ) // WayPoints with Shaders can also use this!
*/

// Shows default values of a HuD
print_default_hud_keys(){

    // Create HuD struct keys
    hud_keys = array( "x", "y", "z", "fontscale", "font", "alignx", "aligny", "horzalign", "vertalign", "color", "alpha", "label", "sort", "foreground",
        "hidewhendead", "hidewheninkillcam", "hidewhenindemo", "immunetodemogamehudsettings", "immunetodemofreecamera", "hidewhileremotecontrolling",
        "hidewheninmenu", "hidewheninscope", "fadewhentargeted", "fontstyle3d", "font3duseglowcolor", "glowcolor", "glowalpha", "archived", "showplayerteamhudelemtospectator" );

    // Create the number of HUDs needed
    level create_huds( hud_keys.size );

    // Creates a test hud to check default values
    level.test_hud = NewHudElem();

    // Loop through every possible HuD struct value
    for (i = 0; i < hud_keys.size; i++)
    {
        if( !isdefined( level._hud[ i ] ) ) break; // There is no HuD to print
        // Get that specific HuD struct value
        value = get_default_hud_value( hud_keys[ i ] );

        // Display the value only if its defined, otherwise the text would not show
        if( isdefined( value ) ){
            level._hud[ i ] BindConfigString( "^6"+hud_keys[ i ]+"^7: ^2"+value );
        }else{
            level._hud[ i ] BindConfigString( "^6"+hud_keys[ i ]+"^7: ^1UNDEFINED" );
        }
    }

    // We no longer need the HuD
    level.test_hud destroy();

}

// Returns the value of the default HuD
get_default_hud_value( struct_param = undefined ){

    // Get HuD struct value
    switch( struct_param ){
        case "x": return level.test_hud.x;
        case "y": return level.test_hud.y;
        case "z": return level.test_hud.z;
        case "fontscale" : return level.test_hud.fontscale;
        case "font": return level.test_hud.font;
        case "alignx": return level.test_hud.alignx;
        case "aligny": return level.test_hud.aligny;
        case "horzalign": return level.test_hud.horzalign;
        case "vertalign": return level.test_hud.vertalign;
        case "color": return level.test_hud.color;
        case "alpha": return level.test_hud.alpha;
        case "label": return level.test_hud.label;
        case "sort": return level.test_hud.sort;
        case "foreground": return level.test_hud.foreground;
        case "hidewhendead": return level.test_hud.hidewhendead;
        case "hidewheninkillcam": return level.test_hud.hidewheninkillcam;
        case "hidewhenindemo": return level.test_hud.hidewhenindemo;
        case "immunetodemogamehudsettings": return level.test_hud.immunetodemogamehudsettings;
        case "immunetodemofreecamera": return level.test_hud.immunetodemofreecamera;
        case "hidewhileremotecontrolling": return level.test_hud.hidewhileremotecontrolling;
        case "hidewheninmenu": return level.test_hud.hidewheninmenu;
        case "hidewheninscope": return level.test_hud.hidewheninscope;
        case "fadewhentargeted": return level.test_hud.fadewhentargeted;
        case "fontstyle3d": return level.test_hud.fontstyle3d;
        case "font3duseglowcolor": return level.test_hud.font3duseglowcolor;
        case "glowcolor": return level.test_hud.glowcolor;
        case "glowalpha": return level.test_hud.glowalpha;
        case "archived": return level.test_hud.archived;
        case "showplayerteamhudelemtospectator": return level.test_hud.showplayerteamhudelemtospectator;
    }

    IPrintLn_all( "Error, couldn't find HuD struct param: ^1"+struct_param );
    return undefined;
}

/* HUD value types */
set_start_timer( b_show_tenths ){

    hud = init_hud( "left_top" );
    hud.alpha = 1; // Make it visible
    hud.label = &"Time: ^5";

    flag_wait( "initial_blackscreen_passed" );

    if( b_show_tenths ){
        WAIT_SERVER_FRAME
        hud SetTenthsTimerUp( SERVER_FRAME );
    }else{
        hud SetTimerUp( 0 );
    }
}

set_countdown_timer( b_show_tenths, time ){

    hud = init_hud( "right_bottom" );
    hud.label = &"Countdown: ^6";
    hud.alpha = 1; // Make it visible

    /* BE CAREFUL!
        Since we are setting the alignments on bottom right, the coordinates 0,0 means
        the bottom right corner, therefore to make it visible, we have to make sure the position
        is 0 or lower;
    */
    if( hud.x > 0 ) hud.x = 0 - hud.x;
    if( hud.y > 0 ) hud.y = 0 - hud.y;

    flag_wait( "initial_blackscreen_passed" );

    if( b_show_tenths ){
        WAIT_SERVER_FRAME
        hud SetTenthsTimer( time );
    }else{
        hud SetTimer( time );
    }

}

set_zombie_counter(){

    hud = init_hud( "right_top" );
    hud.alpha = 1; // Make it visible
    hud.label = &"Zombies Alive: ^8";

    /* BE CAREFUL!
        Since we are setting the alignments on right, the coordinate x = 0 means
        the right side of the screen!, therefore to make it visible, we have to make sure the position
        is 0 or lower;
    */
    if( hud.x > 0 ) hud.x = 0 - hud.x;

    old_val = 0;
    hud SetValue( old_val );

    flag_wait( "initial_blackscreen_passed" );

    for(;;){
        WAIT_SERVER_FRAME

        // Get current zombies
        zombies = getaiarray( level.zombie_team );

        // Get n zombies alive
        if ( isdefined( zombies ) && zombies.size > 0 )
            new_val = zombies.size;
        else
            new_val = 0;

        // Avoid setting the same value again
        if( old_val == new_val ) continue;

        old_val = new_val;
        hud SetValue( old_val );
    }

}

set_host_name(){
    level endon( "game_ended" );

    hud = init_hud( "left_bottom" );
    hud.alpha = 1; // Make it visible
    hud.label = &"Host Name: ^9";

    /* BE CAREFUL!
        Since we are setting the alignments on bottom, the coordinate y = 0 means
        the bottom side of the screen!, therefore to make it visible, we have to make sure the position
        is 0 or lower;
    */
    if( hud.y > 0 ) hud.y = 0 - hud.y;

    hud2 = init_hud( "left_bottom" );
    hud2.alpha = 1; // Make it visible
    hud2.label = &"Host Name: ^9";
    hud2.fontstyle3d = "shadowedmore";
    hud2.glowcolor = ( 0.3, 0.6, 0.3 );
    hud2.glowalpha = 1;

    if( hud2.y > 0 ) hud2.y = 0 - hud2.y;

    host_player = undefined;
    while( !isdefined( host_player ) ){
        WAIT_SERVER_FRAME

        players = GetPlayers();

        // No players found
        if( !isdefined( players ) || players.size < 1 ) continue;

        foreach( player in players ){
            if( player ishost() ){
                host_player = player;
                break;
            }
        }

    }

    flag_wait( "initial_blackscreen_passed" );

    // Normal text
    hud SetText( host_player.name );

    // Text with Glow and effect
    hud2 SetText( host_player.name );
    duration_decoding = 175;
    duration = 60000;
    time2 = 600;
    hud2 setcod7decodefx( duration_decoding, duration, time2 );

}

show_shader_color( color ){
    level endon( "game_ended" );

    hud = init_hud( "fullscreen_fullscreen" );
    hud.x = 0;
    hud.y = 0;
    hud SetShader( "white", 640, 480 );

    flag_wait( "initial_blackscreen_passed" );
    wait 2;

    IPrintLnBold_all("Making shader visible");
    hud FadeOverTime( 5 );
    hud.alpha = 0.5; // Make it visible
    wait 5;

    IPrintLnBold_all("Making shader smaller");
    hud scaleovertime( 3, 320, 240 );
    wait 3;
    
    IPrintLnBold_all("Shader custom color");
    hud fadeovertime( 3 );
    hud.alpha = 1;
    hud.color = color;
    wait 3;

    // R
    IPrintLnBold_all("Shader Red");
    hud fadeovertime( 3.0 );
    hud.color = (1,0,0);
    wait 3;

    // G
    IPrintLnBold_all("Shader Green");
    hud fadeovertime( 3 );
    hud.color = (0,1,0);
    wait 3;

    // B
    IPrintLnBold_all("Shader Blue");
    hud fadeovertime( 3 );
    hud.color = (0,0,1);
    wait 3;

    IPrintLnBold_all("Creating new HuD");
    hud2 = init_hud( "fullscreen_fullscreen" );
    hud2.x = 70;
    hud2.y = 70;
    hud2 SetShader( "white", 360, 280 );
    hud2.sort = 1;
    hud2 fadeovertime( 1.0 );
    hud2.alpha = 1;
    wait 3;

    IPrintLnBold_all("Changing Sort");
    hud.sort = 2;
    wait 3;
    
    IPrintLnBold_all("Changing Foreground");
    hud2.foreground = true;
    wait 3;

    IPrintLnBold_all("Moving HUDs!");
    hud moveovertime( 3 );
    hud.x += 20;
    hud.y += 20;

    hud2 moveovertime( 3 );
    hud2.x -= 20;
    hud2.y -= 20;
}

show_shaders(){

    // Create the number of HUDs needed
    level create_huds( level.shader_names.size );

    // Loop through every possible HuD struct value
    for (i = 0; i < level.shader_names.size; i++)
    {
        self._hud[ i ].label = istring( level.shader_names[ i ] );
        self._hud[ i ] SetShader( level.shader_names[ i ], 40, 10);
    }

}

// Shader on fullscreen
show_fullscreen_shader(){

    full_mapname = MAP_NAME; // Get maps name

    // If map has more than 1 startlocation then we get it through the dvar, otherwise its just the map name without "zm_"
    // IDK why motd works since it has grief mode and die rise apparently was going to get more modes
    mapname = ( full_mapname == TRANZIT || full_mapname == DIE_RISE || full_mapname == BURIED ) ? tolower( getdvar( "ui_zm_mapstartlocation" ) ) : StrTok( full_mapname, "_" )[ 1 ];

    zmb_mode = tolower( getdvar( "ui_gametype" ) ); // Get game mode
    fake_load_screen = "loadscreen_"+full_mapname+"_"+zmb_mode+"_"+mapname;
    precacheshader( fake_load_screen );

    while( !isdefined( level.introscreen ) )
        WAIT_SERVER_FRAME

    level.introscreen SetShader(fake_load_screen, 640, 480); // I copied 640x480 because thats what 3arc uses on the stock scripts for fullscreen shaders
}

/* WAYPOINTS */
// Create a 3D HuD
waypoint_zombie(){
    level endon( "game_ended" );
    self endon( "disconnect" );

    shader = "specialty_instakill_zombies";

    hud_elem = newclienthudelem( self );                // Make one per player so its each player sees the closest zombie to him
    hud_elem.archived = 1;                              // Archived makes the HuD to be on a different pool to avoid overflow
    b_constant_size = true;
    hud_elem setwaypoint( b_constant_size, shader );     // Make it a waypoint so its 3D located and set the shader
    hud_elem.foreground = false;                        // Foreground makes the hud to be always on bottom against another hud without foreground even if .sort is higher
    hud_elem.hidewheninmenu = 1;                        // Dont show it while paused
    hud_elem.alpha = 0;                                 // Make it invisible

    // Destroy the HuD when the player disconnects
    self thread watch_for_disconnect( hud_elem );
    self waittill( "spawned_player" );                  // Wait until we spawn for the first time


    // Update the HuD position
    for(;;){
        WAIT_SERVER_FRAME

        if( !isdefined( self.sessionstate ) || self.sessionstate != "playing" ){   // Make sure the player is playing
            hud_elem.alpha = 0;
            continue;
        }

        zombies = getaispeciesarray( "axis", "all" );
        if( !isdefined( zombies ) || zombies.size < 1 ){   // Check if there is at least 1 zombie
            hud_elem.alpha = 0;
            continue;
        }

        closest_zombie = zombies[ 0 ];
        for( i=1; i<zombies.size; i++){ // Check which zombie is the closest one
            if( distancesquared( self.origin, closest_zombie.origin ) < distancesquared( self.origin, zombies[ i ].origin ) ) continue; // Ignore the zombie if its further than the current closest
            closest_zombie = zombies[ i ];
        }

        head_origin = closest_zombie gettagorigin( "j_head" );

        hud_elem.x = head_origin[0];
        hud_elem.y = head_origin[1];
        hud_elem.z = head_origin[2];

        hud_elem.alpha = 1;

        if( !isdefined( hud_elem.closest_zombie ) || hud_elem.closest_zombie != closest_zombie ){
            hud_elem.closest_zombie = closest_zombie;
            hud_elem scaleovertime( SERVER_FRAME, 32, 32 );
            WAIT_SERVER_FRAME

            hud_elem scaleovertime( 1, 8, 8 );
        }

    }

}

// Destroy the HuD when
watch_for_disconnect( hud ){
    hud endon( "death" );           // Death is the notify sent when you destroy a HuD

    self waittill( "disconnect" );
    hud destroy();                  // destroy() is the proper way delete a HuD, dont make the var undefined
}

/* OVERFLOW */
// Example of overflow
overflow_fix_test(){

    text = Text( "HuD Number:^6 0", 10, 10, "default", 1, Color(0xFFFFFF), 1, 10 );

    for(i=1;;i++){
        WAIT_SERVER_FRAME
        //text SetText( "HuD Number:^6 "+i );           // This makes overflow error to appear!
        text BindConfigString( "HuD Number:^6 "+i );    // This uses serious overflow fix!
    }

}

// Buttons
is_button_pressed( button = undefined ){

    if( !isdefined( button ) ){
        IPrintLn_all( "^1FORGOT TO ADD BUTTON ON ^7is_button_pressed" );
        return false;
    }

    if( !IsPlayer( self ) ){
        IPrintLn_all( "^1Not a player on ^7is_button_pressed" );
        return false;
    }

    self endon( "disconnect" );
    
    switch( button ){

        // Combat
            // Shoot
            case "attack"               : return self attackbuttonpressed();            // MOUSE1
            // Toggle ADS when active
            case "speed_throw"          : return self adsbuttonpressed();               // MOUSE2
            // Whenever ADS button is being pressed
            case "throw"                : return self throwbuttonpressed();             // MOUSE2
            // Interact
            case "activate"             : return self usebuttonpressed();               // F
            // Melee
            case "melee"                : return self meleebuttonpressed();             // V
            // Frag
            case "frag"                 : return self fragbuttonpressed();              // G
            // Monkey Bombs
            case "smoke"                : return self secondaryoffhandbuttonpressed();  // 4

        // Movement
            // Change Stance
            case "stance"               : return self stancebuttonpressed();            // C
            // Jump
            case "gostand"              : return self jumpbuttonpressed();              // SPACE 
            // Sprint
            case "sprint"               :// return self sprintbuttonpressed();
            case "breath_sprint"        : return self sprintbuttonpressed();            // SHIFT
            // Change seat
            case "switchseat"           : return self changeseatbuttonpressed();        // 1

            // Move forward
            case "forward"              : return vectordot( vectornormalize( self getvelocity() ), vectornormalize( anglestoforward( self getplayerangles() ) ) ) > 0.5; // W
            // Move backward
            case "back"                 : return vectordot( vectornormalize( self getvelocity() ), vectornormalize( anglestoforward( self getplayerangles() ) ) ) < -0.5; // S
            // Move left
            case "moveleft"             : return vectordot( vectornormalize( self getvelocity() ), vectornormalize( anglestoright( self getplayerangles() ) ) ) < -0.5; // A
            // Move right
            case "moveright"            : return vectordot( vectornormalize( self getvelocity() ), vectornormalize( anglestoright( self getplayerangles() ) ) ) > 0.5; // D

        // Action slots
            // Shield
            case "actionslot 1"         : return self actionslotonebuttonpressed();     // 1
            // Quadrotor on Origins
            case "actionslot 2"         : return self actionslottwobuttonpressed();     // 2
            // Claymores
            case "actionslot 3"         : return self actionslotthreebuttonpressed();   // 5
            // Special slots like Staffs reviving shoots
            case "actionslot 4"         : return self actionslotfourbuttonpressed();    // 3

        // Unknown or not working
            case "weapnext_inventory"    : return self inventorybuttonpressed(); // Doesn't work on plutonium as 15/08/2025, maybe it does on infinity loader or Steam with GSX studio
        
        // Button that can not be checked
            default:
            {
                self iPrintLn( "^1Error, impossible to check for button: ^6"+button );
                return false;
            }
    }
}

// Shows buttons currently held by the player
check_all_player_buttons(){
    self endon( "disconnect" );

    self._x = HUD_PLAYER_X;
    self._y = HUD_PLAYER_Y;

    if( self IsHost() ){
        level.button_names = array( 
        "attack", "speed_throw", "throw", "frag", "smoke", "melee", "activate", "weapnext_inventory", "switchseat", // Action
        "forward", "back", "moveleft", "moveright", "sprint", "breath_sprint", "stance", "gostand",                 // Movement
        "actionslot 1", "actionslot 2", "actionslot 3", "actionslot 4" );                                           // Action Slots
    }else{
        while( !isDefined( level.button_names ) ) WAIT_SERVER_FRAME
        wait 0.1;
    }

    // Create the number of HUDs needed
    self create_huds( level.button_names.size ); // This is the custom function I created to create HUDs quickly!
    /* How 3arc usually creates HUDs
        hud createfontstring( font, titlesize ); // Basic HUD creation
        hud setpoint( point, relativepoint, xoffset, yoffset, movetime ); // Coordinates and move
    */

    for(;;){
        WAIT_SERVER_FRAME

        // Go throuhg all the HUDs
        for( i = 0; i<level.button_names.size; i++){
            if( !isdefined( self._hud[ i ] ) ) break; // There is no HuD to print

            
            if( self is_button_pressed( level.button_names[ i ] ) ){
                self._hud[ i ] BindConfigString( level.button_names[ i ]+" ^6"+get_button_symbol( level.button_names[ i ] )+"^7: ^2 Pressed!" );
            }
            else{
                self._hud[ i ] BindConfigString( level.button_names[ i ]+" ^6"+get_button_symbol( level.button_names[ i ] )+"^7: ^1Not pressed..." );
            }
        }
    }
}

// To get a button symbol you have to do "[{+bind}]"
get_button_symbol( button_name ){
    if( !isDefined( button_name ) ){
        IPrintLn_all( "^1Error, undefined button to get symbol" );
        IPrintLnBold_all( "^1Error, undefined button to get symbol" );
        return "";
    }

    return "[{+"+button_name+"}]";
}


/*MY FUNCTIONS TO QUICKLY CREATE A HUD*/

// Basic HuD create function
init_hud( _alignment = undefined ){

    if( IsPlayer( self ) ){
        hud = newClientHudElem( self );
        if( !isdefined( _alignment ) ) _alignment = "right_top";
    }else{
        hud = newHudElem();
        if( !isdefined( _alignment ) ) _alignment = "left_top";
    }
    
    // Start making the HuD invisible
    hud.alpha = 0;

    hud.x = self._x;
    hud.y = self._y;
    self._y += 10;

    hud hud_set_alignment( _alignment );

    return hud;
}

// Set hud alignment
hud_set_alignment( _alignment ){

    // In case there is no specified alignment
    if( !isdefined( _alignment ) ){

        // X
        self.horzalign = "center_adjustable";
        self.alignx = "center";

        // Y
        self.vertalign = "top_adjustable";
        self.alignx = "top";

        return;
    }

    alignments = strTok( _alignment, "_" );

    // X
    if( is_valid_horzalign( alignments[0] ) ){
        if( alignments[0] == "fullscreen" ) self.horzalign = "fullscreen";
        else self.horzalign = "user_"+alignments[0];
        self.alignx = alignments[0];
        level thread IPrintLn_All( "^2Horizontal alignment: ^5"+alignments[0] );
    }else{
        self.horzalign = "center_adjustable";
        self.alignx = "center";
        level thread IPrintLn_All( "^1Invalid horizontal alignment: ^5"+alignments[0] );
    }

    // Y
    if( is_valid_vertalign( alignments[1] ) ){
        if( alignments[1] == "fullscreen" ) self.vertalign = "fullscreen";
        else self.vertalign = "user_"+alignments[1];
        self.aligny = alignments[1];
        level thread IPrintLn_All( "^2Vertical alignment: ^5"+alignments[1] );
    }else{
        self.vertalign = "top_adjustable";
        self.aligny = "top";
        level thread IPrintLn_All( "^1Invalid vertical alignment: ^5"+alignments[1] );
    }

}

// Assumes fullscreen is not used
is_valid_horzalign( _align ){

    return _align == "left" || _align == "center" || _align == "right" || _align == "fullscreen";
}

// Assumes fullscreen is not used
is_valid_vertalign( _align ){

    return _align == "top" || _align == "middle" || _align == "bottom" || _align == "fullscreen";    
}

// Automatically creates the number of HUDs desired
create_huds( n_huds ){

    // Check for invalid number
    if( !IS_TRUE( n_huds ) || !IsInt( n_huds ) || n_huds < 1 ){
        n_huds = 4;
        self iPrintLn( "Creating HUDs: ^6"+n_huds );
    }

    // Create an empty array to store them
    self._hud = [];
    for( i=0; i<n_huds; i++){
        self._hud[ i ] = self init_hud();                 // Create the HuD
        //self._hud[ i ] = self init_hud( "left_top" );                 // Create the HuD
        self._hud[ i ] BindConfigString( "^7Example Text ^6"+(i+1) );  // Give some Default text
        self._hud[ i ].alpha = 1;                                      // Make it visible
    }

}

/*MY FUNCTIONS TO MESSAGE ALL PLAYERS*/

// Print a message to all players
IPrintLn_all(text){

    if( !isdefined( text ) || text == "" ){
        text = "^1You forgot to add a text!";
    }

    players = GetPlayers();
    for( i=0; i<players.size; i++){
        players[ i ] IPrintLn( text );
    }

}

// Print a bold message to all players
IPrintLnBold_all(text){

    if( !isdefined( text ) || text == "" ){
        text = "^1You forgot to add a text!";
    }

    players = GetPlayers();
    for( i=0; i<players.size; i++){
        players[ i ] IPrintLnBold( text );
    }

}