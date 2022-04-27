package dice.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import dice.util.Util;

@ignoreCoverage
class RollParsingMacros {
    /**
        Generates the over all regular expression that validates and initially parses the die expression.
    **/
    public static macro function buildSimpleRollExpression(only_complete : Bool = true) : ExprOf<String> {
        var base_string = "([0-9]*)d([0-9]+)";
        var modifiers : Map<String, String> = [];
        for (mod_key in Type.getClassFields(dice.enums.Modifier)) {
            var value = Reflect.field(dice.enums.Modifier, mod_key);
            modifiers[mod_key] = value;
        }
        
        var modifier_matchers = [for (mod_key => mod in modifiers) Util.constructMatcher(mod)];
        var joined_mods = modifier_matchers.join('|');
        var full_string = '$base_string(?:$joined_mods)*';  
        if(only_complete) {
            full_string = '^$full_string' + "$";
        }
        return macro $v{ full_string };
    }
}