package dice;

import dice.expressions.SimpleRoll;
import dice.expressions.ComplexExpression;
using StringTools;

#if macro
    import haxe.macro.Context;
    using haxe.macro.ExprTools;
#end

/**
    `RollManager` manages all the libary functionality, providing access to an expression parser and evaluator, 
    as well as general die rolling functionality
**/
class RollManager {
    /**
        The randomness generator class used by this manager, and all dice and expressions yielded from it
    **/
    public var generator : RandomGenerator;

    /**
        @param generator Optionally pass in custom `RandomGenerator` (For overriding the RNG). 
        In almost all cases, you won't need/want to do this.
    **/
    public function new(?generator : RandomGenerator) {
        this.generator = (generator != null) ? generator : new RandomGenerator();
    }

    /**
        Fetches a basic die with the specified number of sides, passing in the randomness generator from the `RollManager`

        @param sides Number of sides
    **/
    public function getRawDie(sides:Int) : RawDie {
        return new RawDie(sides, generator);
    }

    /**
        Fetches a die with the specified number of sides, passing in the randomness generator from the `RollManager`

        @param sides Number of sides
        @param explode Should die 'explode' (i.e. Roll again and add the result, on results above this integer)
        @param penetrate If die explodes, subtract one from result before adding subsequent results
    **/
    public function getDie(sides:Int, ?explode:Int, ?penetrate:Bool) : Die {
        return new Die(sides, generator, explode, penetrate);
    }

    /**
        Returns a built SimpleRoll object based on the provided expression. This is generated at compiletime, if provided as a string literal,
        or at runtime, if a dynamic expression is provided.

        @param manager (This) Manager to provide for randomness
        @param expression Expression string (e.g. `"5d8!"`)
    **/
    @:ignoreCoverage
    public macro function getSimpleRoll(manager: ExprOf<RollManager>, expression:ExprOf<String>) : ExprOf<SimpleRoll> {
        var expressionLiteral = switch (expression.expr) {
            case EConst(CString(s)): s;
            default: null;
        }
        try {
            var expr = @:privateAccess SimpleRoll.parseExpression(expressionLiteral);
            return macro {
                ({
                    sides: $v{ expr.sides },
                    number: $v{ expr.number },
                    explode: $v{ expr.explode },
                    penetrate: $v{ expr.penetrate },
                    keepLowestNumber: $v{ expr.keepLowestNumber },
                    keepHighestNumber: $v{ expr.keepHighestNumber },
                    expression: $v{ expressionLiteral },
                    manager: $manager
                }
                : dice.expressions.SimpleRoll);
            }
        } catch (e) {
            return macro $manager.getSimpleRollRuntime($expression);
        }
    }

    /**
        Returns a built SimpleRoll object based on the provided expression. This is generated at runtime.

        @param expression Expression string (e.g. `"5d8!"`)
    **/
    public function getSimpleRollRuntime(expression:String) : SimpleRoll {
        return SimpleRoll.fromExpression(this, expression);
    }

    /**
        Generated a complex expression based on the passed expression string. This is generated at compiletime, if provided as a string literal,
        or at runtime, if a dynamic expression is provided.

        @param manager (This) Manager to provide for randomness
        @param expression e.g. `3d6! + 5` or `2d6 * d4`
        @param logRolls Flag to enable automatic logging of each roll result to the expression `logs` property
    **/
    @:ignoreCoverage
    public macro function getComplexExpression(manager: ExprOf<RollManager>, expression:ExprOf<String>, ?logRolls : ExprOf<Bool>) : ExprOf<ComplexExpression> {
        var expressionLiteral = switch (expression.expr) {
            case EConst(CString(s)): s;
            default: null;
        }
        try {
            var parsedExpression = dice.expressions.ComplexExpression.parseExpressionString(expressionLiteral);
            if (!parsedExpression.trim().endsWith(";")) {
                parsedExpression = '$parsedExpression;';
            }
            var parsedExpression = "{ " + dice.expressions.ComplexExpression.expressionPreamble() + "\n" + parsedExpression + " }";
            var nativeExpression = Context.parse(parsedExpression, Context.currentPos());

            var nativeExecutor = macro self -> {
                @:pos(Context.currentPos()) var roll = @:privateAccess self.rollFromParams;
                @:pos(Context.currentPos()) var log = @:privateAccess self.log;
                @:pos(Context.currentPos())
                $e{ nativeExpression };
            }
            return macro $manager.getComplexExpressionRuntime($expression, $logRolls, $nativeExecutor);
        } catch (e) {
            if (expressionLiteral != null ) {
                Context.warning('Unable to parse literal "$expressionLiteral" into a native executor', Context.currentPos());
            }
            return macro $manager.getComplexExpressionRuntime($expression, $logRolls);
        }
    }

    /**
        Generated a complex expression based on the passed expression string. This is generated at runtime.

        @param expression e.g. `3d6! + 5` or `2d6 * d4`
        @param logRolls Flag to enable automatic logging of each roll result to the expression `logs` property
    **/
    public function getComplexExpressionRuntime(expression: String, ?logRolls : Bool, ?nativeExecutor: ComplexExpression -> Any) : ComplexExpression {
        return new ComplexExpression(this, expression, logRolls, nativeExecutor);
    }
}