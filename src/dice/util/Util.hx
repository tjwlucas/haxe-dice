package dice.util;

class Util {
    public static function constructMatcher(mod:String, param:String = '[0-9]*') {
        return '$mod($param)?(?!.*$mod$param)';
    }
}