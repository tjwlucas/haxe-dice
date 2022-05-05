package dice.util;

class Util {
    /**
        Constructs the regex to match the provided modifier (and parameter format).
        The provided expression also verifies that the specified modifier is only present once.
        (If it is present more than once, it will cause the entire expression not to match, which in the 
        parser will result in an `InvalidExpression` error)

        @param mod The modifier to construt a matcher for (e.g. `k` to match `3d6k2`)
        @param param Regex to match following the modifier (e.g in `"3d6k2"`, `k` expects a number following, so `[0-9]*`) 
    **/
    public static function constructMatcher(mod:String, param:String = '[0-9]*') {
        return '($mod)($param)?(?![^\\s]*$mod$param)';
    }
}