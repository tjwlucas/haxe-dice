package dice;

import dice.expressions.SimpleRoll;
import dice.expressions.ComplexExpression;

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
        @param expression Optionally pass a simple expression to be parsed by `SimpleRoll.parse()`
    **/
    public function getSimpleRoll(expression: String) : SimpleRoll {
        return SimpleRoll.fromExpression(this, expression);
    }

    /**
        Generated a complex expression based on the passed expression string.

        @param expression e.g. `3d6! + 5` or `2d6 * d4`
        @param logRolls Flag to enable automatic logging of each roll result to the expression `logs` property
    **/
    public function getComplexExpression(expression: String, ?logRolls : Bool) : ComplexExpression {
        return new ComplexExpression(this, expression, logRolls);
    }
}