package dice.expressions;

import hscript.Expr;

/**
    Subclass of hscript interpreter to add some custom behaviour, such as mathematical functions, and remap the `^` operator
    from the default bitwise XOR to mathematical power.
**/
class ExpressionInterpreter extends hscript.Interp {
    /**
        @param injectedVariables Map of variables to inject into interpreter environment, of the form `["var_name" => value]`
    **/
    public function new(injectedVariables : Map<String, Any>) {
        super();
        variables.set("max", Math.max);
        variables.set("min", Math.min);
        variables.set("floor", Math.floor);
        variables.set("ceil", Math.ceil);
        variables.set("round", Math.round);
        variables.set("abs", Math.abs);
        binops.set("^", power);
        for (name => value in injectedVariables) {
            variables.set(name, value);
        }
    }

    function power(a : Expr, b: Expr) : Float {
        var base : Float = expr(a);
        var exponent : Float = expr(b);
        return Math.pow(base, exponent);
    }
}