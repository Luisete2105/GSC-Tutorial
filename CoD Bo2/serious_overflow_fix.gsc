// Original Serious overflow fix https://github.com/seriousyt/iw-gsc-util/blob/master/serious-gsc.gsc
// Serious video https://www.youtube.com/watch?v=pGAw8QLT5V8

/*
    serious mw3 utility ported to bo2 plutonium by Luisete2105
    youtube.com/anthonything
    
    Note: Please remember to thread SOverflowMonitor() in your init function, or some functions will not work correctly.
*/

#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud;

    
// Maximum strings to allow before clearing strings and doing a redraw.
// This number needs to stay relatively low because clearing too many strings at once will cause
// a reliable command overflow and crash the game. I wouldn't go over 100 personally.
#define SL_OVERFLOW_CAP 60

// The number of hud elements to draw before starting to archive (for additional hud space)
#define SL_BEGIN_ARCHIVE 19


// [CALLER] none
// [variable] the variable to convert into a bool
// Safely determine if the input variable is true
#define BOOL( _arg ) ( isdefined( _arg ) && int( _arg ) )


// [CALLER] none
// [variable] the variable to convert to an integer
// Safely convert a variable to an integer (will never return undefined)
integer(variable)
{
    if(!isdefined(int(variable)))
        return 0;
        
    return int(variable);
}

// [CALLER] player
// [shader] The shader to draw (image). Note: This must be precached in init using 'precacheshader' for it to show up correctly.
// [x] X position of the shader (relative to the align input)
// [y] Y position of the shader (relative to the align input)
// [width] Width of the shader
// [height] Height of the shader
// [color] Tint of the shader
// [alpha] The opacity of the shader (0 to 1 scaled, 1 being completely opaque, and 0 being invisible)
// [sort] Z position of the shader (a higher sort will be drawn over a lower sort)
// [?align] The alignment to use when drawing the position of the element relative to its size. (center means to subtract half the width/height from the draw pos)
// [?relative] The relative position to use when placing the element on the screen (ie: TOPRIGHT)
// [?isLevel] Determines if the hud element is to be drawn on a specific client, or for all clients.
// Create an icon and return it.
Icon(shader, x, y, width, height, color, alpha, sort, align = "center", relative = "center", isLevel = false)
{
    if(isLevel)
        icon = maps\mp\gametypes_zm\_hud_util::createServerIcon(shader, width, height);
    else
        icon = self maps\mp\gametypes_zm\_hud_util::createIcon(shader, width, height);
    
    icon SetScreenPoint(align, relative, x, y);
    
    icon.color          = color;
    icon.alpha          = alpha;
    icon.sort           = sort;
    
    icon.hideWhenInMenu = true;
    
    self.sl_hudct = integer(self.sl_hudct + 1);
    icon.archived = (self.sl_hudct > SL_BEGIN_ARCHIVE);
    
    return icon;
}

// [CALLER] player
// [string] The text you want the string to display
// [x] X position of the text (relative to the align input)
// [y] Y position of the text (relative to the align input)
// [font] The font of the text
// [fontscale] The scale of the font for the text
// [color] The color tint of the text
// [alpha] The opacity of the text (0 to 1 scaled, 1 being completely opaque, and 0 being invisible)
// [sort] Z position of the text (a higher sort will be drawn over a lower sort)
// [?align] The alignment to use when drawing the position of the element relative to its size. (center means to subtract half the width/height from the draw pos)
// [?relative] The relative position to use when placing the element on the screen (ie: TOPRIGHT)
// [?isLevel] Determines if the hud element is to be drawn on a specific client, or for all clients.
// Create a text element and return it.
Text(string = "", x, y, font, fontScale, color, alpha, sort, align = "center", relative = "center", isLevel = false)
{
    if(isLevel)
        text = self maps\mp\gametypes_zm\_hud_util::createServerFontString(font, fontScale);
    else
        text = self maps\mp\gametypes_zm\_hud_util::createFontString(font, fontScale);
    
    text SetScreenPoint(align, relative, x, y);
    text BindConfigString(string);
    
    text.color          = color;
    text.alpha          = alpha;
    text.sort           = sort;
    
    text.hideWhenInMenu = true;
    
    self.sl_hudct = integer(self.sl_hudct + 1);
    text.archived = (self.sl_hudct > SL_BEGIN_ARCHIVE);

    return text;
}

// [CALLER] hudelem
// [time] Time to scale the font over
// [scale] Scale to set the font to
// Scale a font over time
FontScaleOverTime(time, scale)
{
    self thread fsot_intern(time, scale);
}

// [CALLER] none
// [value] The RGB color component to convert
// Convert a hex integer into a color vector
color(value)
{
    /*
        Size constraints comment:
        
        Why is this better than rgb = (r,g,b) => return (r/255, g/255, b/255)?
        
        This will emit PSC, GetInt, align(4), value, SFT, align(1 + pos, 4), 4
        rgb... emits PSC, {GetInt, align(4), value}[3], SFT, align(1 + pos, 4), 4
        Vector emits Vec, align(4), r as float, b as float, g as float 
        
        color:  Min: 14, Max: 17
        rgb:    Min: 30, Max: 33
        vector: Min: 13, Max: 16
    */

    return
    (
    (value & 0xFF0000) / 0xFF0000,
    (value & 0x00FF00) / 0x00FF00,
    (value & 0x0000FF) / 0x0000FF
    );
}

// [CALLER] Hud Element
// [point] The alignment to use when drawing the position of the element relative to its size. (center means to subtract half the width/height from the draw pos)
// [relativePoint] The relative position to use when placing the element on the screen (ie: TOPRIGHT)
// [xOffset] Horizontal position relative to the element's parent
// [yOffset] Vertical position relative to the element's parent
// [moveTime] Time that the element will take to reach its destination
// Setpoint, but without being relative adjustable
SetScreenPoint(point, relativePoint, xOffset, yOffset, moveTime)
{
    self maps\mp\gametypes_zm\_hud_util::setPoint(point, relativePoint, xOffset, yOffset, moveTime);
    self.horzAlign = strip_suffix(self.horzAlign, "_adjustable");
    self.vertAlign = strip_suffix(self.vertAlign, "_adjustable");
}

// [CALLER] none
// [array] array to search
// [element] element to search for
// Return true if the element requested is in the array supplied
IsInArray(array, element)
{
   if(!isdefined(element))
        return false;
   foreach(e in array)
        if(e == element)
            return true;
}

// [CALLER] none
// [array] array to modify
// [item] item to add to the array
// [?allow_dupes] if false, the element will only be added if it is not already in the array
// Add an element to an array and return the new array.  
ArrayAdd(array, item, allow_dupes = 1)
{
    if(isdefined(item))
    {
        if(allow_dupes || !IsInArray(array, item))
        {
            array[array.size] = item;
        }
    }
    return array;
}

// [CALLER] none
// [array] array to clean
// Remove any undefined values from an array and return the new array.
ArrayRemoveUndefined(array)
{
    a_new = [];
    foreach(elem in array)
        if(isdefined(elem))
            a_new[a_new.size] = elem;
            
    return a_new;
}

// [CALLER] none
// [array] array to clean
// [value] value to remove from the array
// Remove all instances of value in array
ArrayRemove(array, value)
{
    a_new = [];
    
    foreach(elem in array)
        if(value != elem)
            a_new[a_new.size] = elem;
            
    return a_new;
}

// [CALLER] none
// [array] array to change
// [index] index to use to insert the value
// [value] value to insert into the array
// Insert a value into an array
ArrayInsertValue(array, index, value)
{
    a_new = [];
    
    for(i = 0; i < index; i++)
    {
        a_new[i] = array[i];
    }
    
    a_new[index] = value;
    
    for(i = index + 1; i <= array.size; i++)
    {
        a_new[i] = array[i - 1];
    }
    
    return a_new;
}

// [CALLER] none
// [array] array to search
// [value] value to search for
// Find the index of a value in an array. If the value isnt found, return -1
ArrayIndexOf(array, value)
{
     for(i = 0; i < array.size; i++)
        if(isdefined(array[i]) && value == array[i])
            return i;
            
    return -1;
}

// [CALLER] Text Element
// [string] Text string to bind
// Bind a replicated config string to a text element (SetText)
BindConfigString(string)
{
    level.sl_strings = ArrayAdd(level.sl_strings, string, 0);
    level.sl_huds    = ArrayAdd(level.sl_huds, self, 0);
    self.text        = string;
    
    if(level.sl_strings.size > SL_OVERFLOW_CAP)
    {
        level notify("sl_overflow");
        return;
    }
    
    self SetText(string);
    level notify("new_text");
}

// [INTERNAL] - should not be called manually
// [CALLER] any
// the built in method of handling an overflow
SOverflowMonitor()
{
    level endon("game_ended");
    level.sl_anchortext = "sl_$" + RandomInt(65536);
    
    text       = self maps\mp\gametypes_zm\_hud_util::createFontString("default", 2);
    text SetText(level.sl_anchortext);
    text destroy();
    
    level.sl_huds    = []; //real hud elements
    level.sl_strings = []; //unique strings
    
    while(true)
    {
        level STextMonitor();
        wait .025;
        level.sl_huds = ArrayRemoveUndefined(level.sl_huds);
    }
}

// [INTERNAL] - should not be called manually
// [CALLER] level
// a utility monitor for the overflow fix
STextMonitor()
{
    level endon("game_ended");
    level endon("new_text");
    
    foreach(hud in level.sl_huds)
        hud endon("death");
    
    level waittill("sl_overflow");
    
    level.sl_huds[0] SetText(level.sl_anchortext);
    level.sl_huds[0] ClearAllTextAfterHudElem();
    
    level.sl_strings = [];
    foreach(hud in level.sl_huds)
    {
        if(!isdefined(hud))
            continue;
        
        if(!isdefined(hud.text))
            continue;
            
        level.sl_strings = ArrayAdd(level.sl_strings, hud.text, 0);
        hud SetText(hud.text);
    }
}

// [INTERNAL] - should not be called manually
// [CALLER] hudelem
// [time] Time to scale the font over
// [scale] Scale to set the font to
// Scale a font over time
fsot_intern(time, scale)
{
    //note: this is a really hacky solution but it allows us to use the builtin method while infinity loader is fixed.
    self.inFrames      = time / .066;
    self.outFrames     = 0;
    self.maxfontscale  = scale;
    self.baseFontScale = scale;
    
    ent                = SpawnStruct();
    
    self thread maps\mp\gametypes_zm\_hud::fontPulse(ent);
    
    wait .025;
    waittillframeend;
    
    ent notify("disconnect");
    ent delete();
}

// IW function, taken from MW3 GSC
strip_suffix( var_0, var_1 )
{
    if ( var_0.size <= var_1.size )
        return var_0;

    if ( getsubstr( var_0, var_0.size - var_1.size, var_0.size ) == var_1 )
        return getsubstr( var_0, 0, var_0.size - var_1.size );

    return var_0;
}