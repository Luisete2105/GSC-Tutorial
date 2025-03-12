/* GSC TUTO

    1º) Download Visual Studio Code:
        - Careful to add open folder option.
        - Add GSC syntax hihglighter.

    2º) Download GSC Repo:
        - Use Plutnoium's T4 Repo.

    3º) Useful commands / binds:
        - /bind f1 fast_restart
        - /bind f2 map_restart
        - /bind f3 disconnect
        - /bind f4 quit

    4º) Basics of programing:
        - Basic variables (int, float, string).
        - Array variables.
        - Struct variables.
        - Function pointer variables.

    5º) Operators:
        - Math: +, -, *, /, %
        - Logic: if, else if, else, true, false, !, &&, ||, ==, <, >
        - Loops: for, while and increment(++)/decrement(--) operators.

    6º) Symbols / words YOU MUST LEARN:
        - Tokens: (), [], [[]], #.
        - Keywords: true, false, wait, undefined, if, else if, else, for, while, continue, break, return, level, self, thread, #include, notify, waittill, endon, .size.
*/

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

// This is called everytime a player spawns
onplayerspawned()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
	{
        self waittill( "spawned_player" );
        //self thread basic_variables();
        //self thread array_variables();
        //self thread struct_variables();
        //self thread funcptr_variables();
        //self thread operators_examples_1();
        //self thread operators_examples_2();
        //self thread loop_example_1();
        //self thread loop_example_2();
    }
}

// END OF BASIC PLUTO SCRIPT

// undefined, int, float and string
basic_variables(){

    // EVERYTHING AFTER "//" IS IGNORED! USE IT TO MAKE COMMENTS TO REMEMBER YOU WHAT EACH THING DOES!

    /* Its minimizable!
        THIS IS A MULTI LINE COMMENT
        IT IGNORES EVERYTHING UNTIL YOU 
        SET
        THE
        END
        OF
        THE COMMENT
    */

    // Creating variables!
    //undefined_var   = undefined;        // On other languages its refered as null or void.
    integer_number  = 7;
    float_number    = 7.7;
    bool_true       = true;             // true is the same as 1.
    bool_false      = false;            // false is the same as 0
    string_chain    = "Hello World";    // They have ".size" property!
    
    // Printing variables!
    //self iPrintLnBold("Undefined: " + undefined_var); // Undefined vars are not shown since they do not exist! its not a bug.
    self iPrintLnBold("Int: " + integer_number);
    self iPrintLnBold("Float: " + float_number);
    self iPrintLnBold("True: " + bool_true);
    self iPrintLnBold("False: " + bool_false);
    self iPrintLnBold("String: " + string_chain);
    self iPrintLnBold("String size: " + string_chain.size);
}

// array
array_variables(){

    // Array
    my_list = [];               // Create an empty list

    my_list[0] = 7;             // Asign to index '0' the value 7
    my_list[1] = 7.7;           // Asign to index '1' the value 7.7
    my_list[2] = "Siuuuu!";     // Asign to index '2' the value "Siuuuu!"

    //my_list["a"] = "Letter A";    // Asign to index 'a' the value "Letter A"
    //my_list["b"] = "Letter B";    // Asign to index 'b' the value "Letter B"

    self iPrintLnBold( "list.size: " + my_list.size ); // They have a ".size" property!
    self iPrintLnBold( "list[0]" + my_list[0] );
    //self iPrintLnBold( "my_list[a]: " + my_list["a"] );
}

// struct
struct_variables(){

    // Struct
    my_struct = spawnStruct();              // Create an empty struct
    my_struct.struct_undefined = undefined;
    my_struct.struct_int = 7;
    my_struct.struct_float = 7.777777;
    my_struct.struct_string = "Siuuuu!";
    my_struct.struct_array = (9,8,7);

    self iPrintLnBold( "struct undefined: " + my_struct.struct_undefined );
    self iPrintLnBold( "struct int: " + my_struct.struct_int );
    self iPrintLnBold( "struct string: " + my_struct.struct_string );
    self iPrintLnBold( "struct array[0]: " + my_struct.struct_array[0] );
}

// funcptr
funcptr_variables(){

    // function pointer
    function_pointer = ::say_hello_world; // Notice the "::" to indicate that we are assigning a function as a variable
    self [[ function_pointer ]](); // make sure to use 2 brackets and not one!
}

say_hello_world(){
    self iPrintLnBold( "Hello World!");
}

// operators
operators_examples_1(){

    number_a = 7;
    number_b = 3;

    // Elemental ones
    addition        = number_a + number_b;
    subtraction     = number_a - number_b;
    multiplication  = number_a * number_b;
    division        = number_a / number_b;

    // Returns the remainder of a division after one number is divided by another!
    modulus         = number_a % number_b; // Example: 7 / 3 = 2, remainder 1

    self iPrintLnBold("addition: " + addition);
    self iPrintLnBold("subtraction: " + subtraction);
    self iPrintLnBold("multiplication: " + multiplication);
    self iPrintLnBold("division: " + division);
    self iPrintLnBold("modulus: " + modulus);
}

operators_examples_2(){

    number_a = 7;
    number_b = 3;

    /* IF, IF ELSE, ELSE statements

        - IF 
            Syntax is:
            if( condition ){
                your code   // THIS CODE IS ONLY RUN IS THE CONDITION IS TRUE
            }

            You can add extra cases to evaluate with IF ELSE or only add an alternative case with ELSE.

        - IF ELSE
            Syntax is:
            if( condition_a ){
                your code a
            }else if( condition_b ){
                your code b
            }else if( condition_c ){
                your code c
            }...

            Notice that you can add as many ELSE IF as you want.
            You can add an ELSE statement at the end.
            Once a condition is met, the rest ELSE IF statements are ignored.

        - ELSE
            Syntax is:
            if( condition_a ){
                your code a
            }else{
                code b
            }

            ELSE statements always are at the end.
            ELSE code is never run when the IF condition or any of the ELSE IF conditions is met.

    */

    // Greater than, Equal to, Smaller than operators

    // GREATER THAN
    if(number_a > number_b){
        self iPrintLnBold( "A is GREATER THAN B");
    }
    // EQUAL TO
    else if(number_a == number_b){
        self iPrintLnBold( "A is SAME AS B");
    }
    // SMALLER THAN
    else if(number_a < number_b){
        self iPrintLnBold( "A is SMALLER THAN B");
    }

    // You can add an "=" after to indicate that the same value is included!
    // SMALLER OR EQUAL THAN
    if(number_a <= 7){
        self iPrintLnBold( "A is SMALLER OR EQUAL THAN 3");
    }

    /* Logic operators
        && Used to state that both previous AND next conditions need to be true
        || Used to state that either previous OR next conditions need to be true
        !  Inverts the result of a logical condition, true is converted to false and vice versa
    */

    if(number_b > 0 && number_b < 5){ // Number_b is GREATER than 10 AND Number_b is SMALLER than 10
        self iPrintLnBold( "B is GREATER than 5 AND SMALLER than 10");
    }

    if(number_a < 0 || number_a != 3.14){ // Number_a SMALLER than 0 OR Number_a is NOT 3.14
        self iPrintLnBold( "A is SAMLLER than 0 OR is NOT 3.14");
    }
}

//Loops
loop_example_1(){

    // ++ adds 1 to the variable, its the same as "variable = variable + 1"
    // -- substracts 1 to the variable, its the same as "variable = variable - 1"

    /* FOR loop | should be used when we know we want to execute some code a known amount of times. For example if we want
        syntax:
        for( iterator = value; condition; iterator_change){
            code
        }

        Iterator is the variable we create at the begining, its executed before entering the code inside the FOR loop.
        Condition is the expresion that is evaluated everytime your code inside the loop is going to be executed.
        Iterator change is the operation we are gona do to the Iterator whenever our code inside the FOR loop has been executed.
    */

    wait 2;

    for(i=1; i <= 5; i++){ // Lets make a counter from 1 to 5
        wait 1;
        self iPrintLnBold( i ); // Shows the current value of the iterator
    }

    self iPrintLnBold("Counting to 5 finished!");
}

loop_example_2(){

    /* WHILE loop | Should be used when you dont know for how long you are going to repeat something.
        syntax:
        while( condition ){
            code
        }

        If the condition is literally 1 or true, then its a infinite loop.
        Add always a wait inside a loop that is going to loop many times to avoid the game from crashing.
    */

    wait 2;

    position = self.origin;

    while( position == self.origin ){
        wait 1;
        self iPrintLnBold("You are not moving...");
    }

    self iPrintLnBold("You finally moved!");
}

/* keywords and tokens you must learn

    Tokens are special characters that give the compiler information about what you are going to do.
        ., (), [], {},[[]], #.

    Keywords are specific words that have a functionality, therefore you cant name a variable like any of this.
        true, false, wait, undefined, if, else if, else, for, while, continue, break, return, level, self, thread, #include, notify, waittill, endon, .size.
*/