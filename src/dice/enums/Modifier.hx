package dice.enums;

/**
    Defines allowed 'modifiers' in the basic die epression
**/
enum abstract Modifier(String) to String {
    var KEEP = "[khl]";
    var EXPLODE = "!!?";
}