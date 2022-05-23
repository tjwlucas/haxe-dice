package dice.enums;

/**
    Type of random generator to instantiate. 
    If the `seedyrng` library is imported, gives the option of seedy RNG,  initialised with the provided seed string.
**/
enum RandomGeneratorType {
    /**
        Use built in randomness
    **/
    Default;
    #if seedyrng
        /**
            Only present if the `seedyrng` library is imported. Will use seedy RNG initialised with the provided seed string.
        **/
        Seedy(seed : String);
    #end
}