package dice.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class RollParsingMacros {
    public static macro function buildSimpleRollExpression() : Array<Field> {
        var fields = Context.getBuildFields();    
        
        var base_string = "^([0-9]*)d([0-9]+)";
        var modifiers : Map<String, String> = [];
        for (mod_key in Type.getClassFields(dice.enums.Modifier)) {
            var value = Reflect.field(dice.enums.Modifier, mod_key);
            modifiers[mod_key] = value;
        }

        function constructMatcher(mod:String) {
            return '$mod([0-9]*)?(?!.*$mod[0-9]*)';
        }
        
        var modifier_matchers = [for (mod_key => mod in modifiers) constructMatcher(mod)];
        var joined_mods = modifier_matchers.join('|');
        var full_string = '$base_string(?:$joined_mods)*$';    


        var matcher_map : Map<String, String> = [];
        for (mod_key => mod in modifiers) {
                matcher_map[mod] = constructMatcher(mod);
        }
        
		var tmp_class = macro class {
            @:keep public static inline var MATCHING_STRING = $v{ full_string };

            public static var MATCHER = $v{ matcher_map }

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