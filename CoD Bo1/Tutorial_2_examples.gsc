/* GSC TUTO

    1º) Scopes of variables
        - Local.
        - Global.
        - Dvar.

    2º) How to properly use functions:
        - Identify the "self" entity.
        - Function parameters.
        - Return a value.
        - How to call a function from another script.

    3º) When to thread and use a caller:
        - Thread
        - Functions.
        - Method.

    4º) Efficient api functions
        - Notify.
        - Waittill.
        - Endon.
    
    5º) Coloured texts
        -1 to 9 on iPrintLnBold
*/

//#include maps\_utility;
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
        level waittill( "connected", player ); // Here is the caller entity!
        player thread onplayerspawned();    // Where is this "player" entity created?
	}
}

// This is called everytime a player spawns
onplayerspawned()
{
 
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
	{
        self waittill( "spawned_player" );
        //self thread local_scope();
        //self thread global_scope();
        //self thread developer_vars();
        //self thread who_is_calling_this_function(); // lets go 1 more function deep to discover who is "self"
        //self thread give_me_the_weapons( "ray_gun_zm", "thundergun_zm" );
        //self thread print_zombies_health();
        //self thread print_power_has_been_activated();
        //self thread basic_menu();
        //self thread print_all_colors();
    }

}

// END OF BASIC PLUTO SCRIPT



/* Variable scopes

    *Local Variables
        -Only exist withing their own functions.
        -Their values are reseted on each function call.

    *Global Variables
        -Is shared between all scripts and functions.
        -Its value is reseted when restarting a game, either fast_restart or map_restart.
        -To access it you have to use the default game struct "level", for example level.script.

    *Developer Variables
        -It CAN NOT have a blank space within the name, for example "game speed" is not a valid name, "game_speed" is a valid name.
        -If it doesnt exist a default value is set instead of undefined.
        -Values are preserved until the game is closed or another script script changes it.
        -To change its value you have to use the function SetDvar( dvar_name, value).
        -To get its value you have to use:
            GetDvar( "dvar_name" )         | returns a String   | Default: ""
            GetDvarInt( "dvar_name" )      | returns a Integer  | Default: 0
            GetDvarFloat( "dvar_name" )    | returns a Float    | Default: 0.0
*/

// Notice how the first and second print are the same!
local_scope(){

    local_var = 2;
    self IPrintLnBold( "Local BEFORE: "+local_var ); // 1st print

    // You cant change a local variable from another function!
    change_local_var( local_var );
    wait 2;

    self IPrintLnBold( "Local AFTER: "+local_var ); // 2nd print
    wait 2;

    local_var = 7;
    self IPrintLnBold( "Local FINAL: "+local_var ); // 3rd print
}

// This function essentially does nothing...
change_local_var( local_var ){

    local_var = 7;
}

// Global vars can be accessed from anywhere!
global_scope(){

    level.global_var = 2;
    self IPrintLnBold( "Global BEFORE: "+level.global_var ); // 1st print

    // Notice how we DO NOT NEED to pass the variable as a argument!
    change_global_var();
    wait 2;

    // It will work this time!
    self IPrintLnBold( "Global AFTER: "+level.global_var ); // 2nd print
}

// This doesnt make sense since you can change a Global variable from anywhere, this is just an example
change_global_var(){

    level.global_var = 7;
}

// Dvars are saved until you close the game!
developer_vars(){

    // Dvars return a string!. If the Dvar doesnt exist then its created, default value is an empty string "".
    speed = GetDvar( "speed" );
    speed = int( speed );   // Converting string to int number
    //speed = float( speed ); // Converting string to float number

    // We can use GetDvarInt to skip the conversion
    //speed = GetDvarInt( "speed" );    // If the Dvar doesnt exist then its created with default value 0.

    // Float conversion can also be skipped with GetDvarFloat
    //speed = GetDvarFloat( "speed" );    // If the Dvar doesnt exist then its created with default value 0, same as GetDvarInt
    //self IPrintLnBold( "Currently speed is: ^6" + speed );

    // Speed will be alternating between 1 and 2 each restart, we are checking 0 and "" because they are the default values.
    if( speed == 1 || speed == 0 ){
        self IPrintLnBold( "Currently speed is: ^6" + speed );
        speed = 2;
    }else{
        speed = 1;
    }

    self IPrintLnBold( "Setting speed to: ^4" + speed );
    SetDvar( "speed", speed);
    SetTimeScale( speed );
}



// Lets identify the caller
who_is_calling_this_function(){
    player = self;  // We still need to check where is called this function to see who is "self"
    wait 1;
    player who_is_printing_this_text(); // Lets see which entity is "player"
}

who_is_printing_this_text(){
    wait 1;
    self IPrintLnBold( "Who is the caller?" ); // "self" is the entity that called the function
}



// We are passing the weapon's name as a parameter, the only way to know what is its value is looking the line we are using this function
give_me_the_weapons( weapon_1, weapon_2 ){

    // Wait for the player to get the starting pistol, otherwise samantha is going to steal all weapons
    while( !self hasWeapon( "m1911_zm" ) ){
        wait 0.05;
    }

    // Take the starting pistol from player
    self TakeWeapon( "m1911_zm" );

    // Give the weapons we want
    self GiveWeapon( weapon_1 );
    self GiveWeapon( weapon_2 );
    wait 0.05;
    // Switch to first weapon so we dont get glitched
    self switchToWeapon( weapon_1 );
}



// Getting a value calculated in another function with return!
print_zombies_health(){
    level endon( "game_ended" );
    self endon( "disconnect" );

    for(;;){
        // We will wait 20s into the round to give zombies time to spawn
        for(i=20; i>0; i--){
            self IPrintLnBold(i); // Print the seconds left to wait
            wait 1;
        }

        // This will RETURN the total health of all the zombies alive.
        n_health = get_all_zombies_healths();
        self IPrintLnBold("Currently zombies health is: ^1"+n_health);

        level waittill( "end_of_round" );
    }

}

get_all_zombies_healths(){

    total_health = 0;
    zombies = GetAIArray( "axis" );
    for( i=0; i<zombies.size; i++){
        total_health += zombies[i].health;
    }

    // Once a return statement is hit the function ends even if there is code after it!
    return total_health;
}



/* How to call a function from another script?
    1) You can directly call it by specifying the script it comes from, after it add "::" and finally the function name with its parenthesis.
        Syntax:     caller *optional* + thead *optional* + folder_name\script_name::function_name( argument/s *optional* )
        Example:    level common_scripts\utility::flag_wait( "power_on" );

    2) You can can skipt the script location syntax by adding its #include AT THE BEGINNING of the script.
       Remember that all the files must be included BEFORE defining any function!.
       Syntax:      #include + folder_name\script_name;
                    ...
                    caller *optional* + thead *optional* + function_name( argument/s *optional* )
                    ...
        Example:    #include common_scripts\utility;
                    ...
                    level flag_wait( "power_on" );
                    ...
*/

// Calling functions from another script in 2 different ways
print_power_has_been_activated(){
    level endon( "game_ended" );
    self endon( "disconnect" );

    // Giving points and incrementing speed to make it faster
    self.score = 123456;
    self setMoveSpeedScale( 2 );

    // Calling the function directly from the script location!
    //level common_scripts\utility::flag_wait( "power_on" );

    // Calling the function withou indicating the path since its already done withing the #includes
    level flag_wait( "power_on" );

    self IPrintLnBold( "Power has been activated!" );
    return;
}



/* When to thread a function?
    Theading a function means that the original function its being called from is NOT going to wait for this new function to end, therefore both
    of them are going to be running at the same time.
    A function that contains a infinite loop will almost always need to be threaded, otherwise the function that calls it is going to get stucked indefinitely.
*/

/* Whats then difference between "function" and "method" in GSC?
    *Function: It doesnt need to have a caller to work, if its not specified then "self" is the caller, the entry points have "level" as the default entity caller.
        -Example: SetTimeScale( value );
    *Method: It ALWAYS requires a caller to work, otherwise its going to not compile or crash.
        -Example: Self IPrintLnBold( text );
*/

/* Efficienty functions
    -Caller Waittill( text, arguments *optional* ): Stops the execution of the function until a notify with the same message AND caller is sent. As long as a notify for what you are waiting
               exists, you should use this since its more efficient. Some of them include extra parameters with extra data, if the notify doesnt include the data you expect then 
               a undefined value is sent.

    -Caller Notify( text, arguments *optional* ): Sends a message to all the currently active functions for only that very server tick, only the waittills with the
                     the same caller are the ones receiving it.
                     Sometimes game engine sends notifies by default after certain actions and it often includes extra parameters, check GSC dumps to see examples, it varies from game to game.

    -Caller Endon( text ): Ends the function as soon as a notify is sent with the same text AND caller. Very commonly used on functions with infinite loops
                           where self is the player since a disconnect can happen, it doesnt make sense to check if a disconnected player is meeting any condition.
                           Most common endons are: level endon( "game_ended" ) and self endon( "disconnect" ).
*/

// Thread, Function, Methods, Notify, Waittill, Endon
basic_menu(){
    level endon( "game_ended" );    // Functions ends whenever the "game_ended" notify is hit
    self endon( "disconnect" );     // Functions ends if the player gets disconnected

    self.god_mode = false;
    self.infinite_ammo = false;

    for(;;){
        wait 0.05;

        // God Mode
        if( self UseButtonPressed() ){
        //if( UseButtonPressed() ){ // This is a method! if you dont add the caller its going to crash even if "self" is a player

            // Inefficient
            /*if( self.god_mode ){
                self.god_mode = false;  // Disable God Mode
            }else{
                self thread inefficient_god_mode(); // Enable God Mode
                //self inefficient_god_mode(); // If we dont thread it then we enter this function and since its an infinite loop we are getting stucked in it!
            }*/

            // Efficient and easier to understand
            self thread efficient_god_mode();

            while( self UseButtonPressed() ){
                wait 0.05;
            }
        }

        // Infinite Ammo
        if( self jumpButtonPressed() ){

            // Inefficient
            /*if( self.infinite_ammo ){
                self.infinite_ammo = false;  // Disable Infinite Ammo
            }else{
                self thread inefficient_infinite_ammo(); // Enable Infinite Ammo
            }*/

            // Efficient and easier to read
            self thread efficient_infinite_ammo();

            while( self jumpButtonPressed() ){
                wait 0.05;
            }            
        }

    }

}

// God Mode
efficient_god_mode(){
    level endon( "game_ended" );
    self endon( "disconnect" );

    self notify( "god_mode" );
    self endon ( "god_mode" );

    self.god_mode = !self.god_mode;
    if( !self.god_mode ){
        self IPrintLnBold( "God Mode ^1Disabled" );
        self DisableInvulnerability();
        return;
    }

    self IPrintLnBold( "God Mode ^2Enabled" );

    for(;;){
        wait 0.05;
        self EnableInvulnerability();
    }

}

inefficient_god_mode(){
    level endon( "game_ended" );
    self endon( "disconnect" );

    self.god_mode = true;
    self IPrintLnBold( "God Mode ^2Enabled" );

    while( self.god_mode ){
        wait 0.05;
        self EnableInvulnerability();
    }

    self DisableInvulnerability();
    self IPrintLnBold( "God Mode ^1Disabled" );
}


// Infinite Ammo
efficient_infinite_ammo(){
    level endon( "game_ended" );
    self endon( "disconnect" );

    /*  Q: Why this function is not ending itself as soon as it gets called?
        A: Because the notify is being sent BEFORE we add it as a ending condition!
           This way we end any other instance of this function that is already running.
    */
    self notify( "infinite_ammo" );
    self endon( "infinite_ammo" );

    self.infinite_ammo = !self.infinite_ammo;
    if( !self.infinite_ammo ){
        self IPrintLnBold( "Infinite Ammo ^1Disabled" );
        return;
    }

    self IPrintLnBold( "Infinite Ammo ^2Enabled" );

    for(;;){
        self waittill ( "weapon_fired", curWeapon );
        self SetWeaponAmmoClip( curWeapon, 777 );
    }

}

inefficient_infinite_ammo(){
    self endon( "disconnect" );

    self.infinite_ammo = true;
    self IPrintLnBold( "Infinite Ammo ^2Enabled" );

    while( !level.gameEnded && self.infinite_ammo ){
        wait 0.05;

        weapon = self getCurrentWeapon();
        self SetWeaponAmmoClip( weapon, 777 );
    }

    self IPrintLnBold( "Infinite Ammo ^1Disabled" );
}



/* Color code:
    *To make a text change color you have to do: ^ + number from 0 to 9.
    The text color changes from that moment until it finds another ^ + number. Default color is white which is ^7.
    -0 Black
    -1 Red
    -2 Green
    -3 Yellow
    -4 Dark Blue
    -5 Light Blue
    -6 Pink
    -7 White
    -8 Grey
    -9 Tan / Sand color
*/

// Show colors
print_all_colors(){

    wait 5;

    for(i=0; i<=10; i++){
        self IPrintLnBold( "^"+i+" Color: "+i );
        wait 1;
    }
}