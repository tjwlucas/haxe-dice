package dice.expressions;

/**
    Subclass of hscript interpreter to add some custom behaviour, such as mathematical functions.
**/
class ExpressionInterpreter extends hscript.Interp {
    /**
        @param injectedVariables Map of variables to inject into interpreter environment, of the form `["var_name" => value]`
    **/
    @:allow(dice.expressions.ComplexExpression)
    function new(injectedVariables : Map<String, Any>) {
        super();
        variables.set("Math", Math);
        for (name => value in injectedVariables) {
            variables.set(name, value);
        }
    }
}