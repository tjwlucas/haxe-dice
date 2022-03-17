package dice.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import dice.util.Util;

class RollParsingMacros {
    /**
        Generates the over all regular expression that validates and initially parses the die expression.
    **/
    public static macro function buildSimpleRollExpression() : Array<Field> {
        var fields = Context.getBuildFields();    
        
        var base_string = "^([0-9]*)d([0-9]+)";
        var modifiers : Map<String, String> = [];
        for (mod_key in Type.getClassFields(dice.enums.Modifier)) {
            var value = Reflect.field(dice.enums.Modifier, mod_key);
            modifiers[mod_key] = value;
        }

        
        var modifier_matchers = [for (mod_key => mod in modifiers) Util.constructMatcher(mod)];
        var joined_mods = modifier_matchers.join('|');
        var full_string = '$base_string(?:$joined_mods)*$';    

        
		var tmp_class = macro class {
            /**
                The general regex that will match a valid die expression
            **/
            @:keep public static inline var MATCHING_STRING = $v{ full_string };

            /**
                Validates the provided expression and extracts the initial basic info (number of dice and number of sides)
            **/
            public function parseCoreExpression(expression : String) {
                var matcher = new EReg($v{ full_string }, "i");
                if (matcher.match(expression)) {
                    var number = Std.parseInt(matcher.matched(1));
                    var sides = Std.parseInt(matcher.matched(2));
                    return {
                        number: number,
                        sides: sides
                    };
                } else {
                    throw new dice.errors.InvalidExpression('$expression is not a valid core die expression');
                };
            }
		}

		for (field in tmp_class.fields) {
			fields.push(field);
		}

        return fields;
    }
}