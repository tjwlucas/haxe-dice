package dice.macros;

import dice.util.Util;

/**
    Home for some internal macros to build the regex to match the dice expressions
**/
@ignoreCoverage
class RollParsingMacros {
    /**
        Generates the over all regular expression that validates and initially parses the die expression.

        @param onlyComplete Only matches if the matches string is the entire expression
        @param excludeInQuotations If true, any valid strings are only matched if they are not inside paired '' or ""
    **/
    public static macro function buildSimpleRollExpression(onlyComplete : Bool = true, excludeInQuotations : Bool = false) : ExprOf<String> {
        return macro $v{ doBuildSimpleRollExpression(onlyComplete, excludeInQuotations) };
    }

    #if macro
        @:allow(dice.expressions.ComplexExpression, dice.expressions.SimpleRoll)
        static function doBuildSimpleRollExpression(onlyComplete : Bool = true, excludeInQuotations : Bool = false) : String {
            var baseString = "([0-9]*)d([0-9]+)";
            var modifiers : Map<String, String> = [];
            for (mod_key in Type.getClassFields(dice.enums.Modifier)) {
                var value = Reflect.field(dice.enums.Modifier, mod_key);
                modifiers[mod_key] = value;
            }

            // TODO: This is clumsy, determine a tidier way
            var lookaheads = "";
            if (excludeInQuotations) {
                for (quote in ["'", '"']) {
                    lookaheads += '(?=([^$quote\\\\]*(\\\\.|$quote([^$quote\\\\]*\\\\.)*[^$quote\\\\]*$quote))*[^$quote]*$)';
                }
            }

            var modifierMatchers = [for (mod_key => mod in modifiers) Util.constructMatcher(mod)];
            var joinedMods = modifierMatchers.join("|");
            var fullString = '$baseString(?:$joinedMods)*$lookaheads';
            if (onlyComplete) {
                fullString = '^$fullString' + "$";
            }
            return fullString;
        }
    #end
}