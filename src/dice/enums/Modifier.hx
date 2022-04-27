package dice.enums;

/**
    Defines allowed 'modifiers' in the basic die epression
**/
enum abstract Modifier(String) to String {
    var KEEP_HIGHEST = '[kh]';
    var KEEP_LOWEST = 'l';
    var EXPLODE = '!';
    var PENETRATE = '!!';
}