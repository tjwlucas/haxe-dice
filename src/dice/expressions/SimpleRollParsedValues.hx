package dice.expressions;

/**
    Raw values parsed as an intermediate step between parsing a SimpleRoll expression and building the object
**/
typedef SimpleRollParsedValues = {
    sides: Int,
    number: Int,
    explode: Null<Int>,
    penetrate: Bool,
    keepLowestNumber: Null<Int>,
    keepHighestNumber: Null<Int>
}