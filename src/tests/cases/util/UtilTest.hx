package tests.cases.util;

import dice.util.Util;
import utest.Test;

class UtilTest extends Test {
    function specConstructMatcher() {
        Util.constructMatcher('l') == 'l([0-9]*)?(?!.*l[0-9]*)';
        Util.constructMatcher('[hk]') == '[hk]([0-9]*)?(?!.*[hk][0-9]*)';
        Util.constructMatcher('p', null) == 'p([0-9]*)?(?!.*p[0-9]*)';
        Util.constructMatcher('c', '[<>]?[0-9]+') == 'c([<>]?[0-9]+)?(?!.*c[<>]?[0-9]+)';
    }
}