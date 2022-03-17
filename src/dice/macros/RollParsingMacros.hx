package dice.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class RollParsingMacros {
    public static macro function buildSimpleRollExpression() : Array<Field> {
        var fields = Context.getBuildFields();    
        
        var base_string = "^([0-9]*)d([0-9]+)";
        var modifiers : Array<String> = [];
        for (mod_key in Type.getClassFields(dice.enums.Modifiers)) {
            var value = Reflect.field(dice.enums.Modifiers, mod_key);
            modifiers.push(value);
        }
        var modifier_matchers = [for (mod in modifiers) '$mod([0-9]*)?(?!.*$mod[0-9]*)'];
        var joined_mods = modifier_matchers.join('|');
        var full_string = '$base_string(?:$joined_mods)*$';    


        var get_modifiers : Array<Expr> = [];
        for (i => mod in modifiers) {
            get_modifiers.push(
                macro {
                    parsed_map[$v{mod}] = matcher.matched($v{i + 3});
                }
            );
        }
        
		var tmp_class = macro class {
            @:keep public static inline var MATCHING_STRING = $v{ full_string };

            public function parseRaw(expression : String) {
                var matcher = new EReg($v{ full_string }, "i");
                if (matcher.match(expression)) {
                    var parsed_map : Map<String, String> = [];
                    parsed_map["number"] = matcher.matched(1);
                    parsed_map["sides"] = matcher.matched(2);
                    $b{ get_modifiers };
                    return parsed_map;
                } else {
                    throw "Oops";
                };
            }
		}

		for (field in tmp_class.fields) {
			fields.push(field);
		}

        return fields;
    }
}