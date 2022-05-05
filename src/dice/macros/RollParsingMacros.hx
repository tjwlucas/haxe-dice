package dice.macros;

import dice.util.Util;

/**
    Home for some internal macros to build the regex to match the dice expressions
**/
@ignoreCoverage
class RollParsingMacros {
    /**
        Generates the over all regular expression that validates and initially parses the die expression.

        @param only_complete Only matches if the matches string is the entire expression
        @param exclude_in_quotations If true, any valid strings are only matched if they are not inside paired '' or ""
    **/
    public static macro function buildSimpleRollExpression(only_complete : Bool = true, exclude_in_quotations : Bool = false) : ExprOf<String> {
        var base_string = "([0-9]*)d([0-9]+)";
        var modifiers : Map<String, String> = [];
        for (mod_key in Type.getClassFields(dice.enums.Modifier)) {
            var value = Reflect.field(dice.enums.Modifier, mod_key);
            modifiers[mod_key] = value;
        }

        // TODO: This is clumsy, determine a tidier way
        var lookaheads = "";
        if(exclude_in_quotations) {
            for(quote in ["'", '"']) {
                lookaheads += '(?=([^$quote\\\\]*(\\\\.|$quote([^$quote\\\\]*\\\\.)*[^$quote\\\\]*$quote))*[^$quote]*$)';
            }
        }
        
        var modifier_matchers = [for (mod_key => mod in modifiers) Util.constructMatcher(mod)];
        var joined_mods = modifier_matchers.join("|");
        var full_string = '$base_string(?:$joined_mods)*$lookaheads';  
        if(only_complete) {
            full_string = '^$full_string' + "$";
        }
        return macro $v{ full_string };
    }
}