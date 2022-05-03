package dice;

import dice.expressions.SimpleRoll;
import dice.expressions.ComplexExpression;

/**
    `RollManager` manages all the libary functionality, providing access to an expression parser and evaluator, 
    as well as general die rolling functionality
**/
class RollManager {
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
    **/
    public function getRawDie(sides:Int) : RawDie {
        return new RawDie(sides, generator);
    }

    /**
        Fetches a die with the specified number of sides, passing in the randomness generator from the `RollManager`
    **/
    public function getDie(sides:Int, ?explode:Int, ?penetrate:Bool) : Die {
        return new Die(sides, generator, explode, penetrate);
    }

    /**
        @param expression Optionally pass a simple expression to be parsed by `SimpleRoll.parse()`
    **/
    public function getSimpleRoll(?expression: String) {
        return new SimpleRoll(this, expression);
    }

    /**
        Generated a complex expression based on the passed expression string.

        e.g. `3d6! + 5` or `2d6 * d4`
    **/
    public function getComplexExpression(expression: String, ?logRolls : Bool) {
        return new ComplexExpression(this, expression, logRolls);
    }
}