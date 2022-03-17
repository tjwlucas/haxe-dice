package dice.enums;

enum abstract Modifier(String) to String {
    var KEEP_HIGHEST = '[kh]';
    var KEEP_LOWEST = 'l';
    var EXPLODE = '!';
}