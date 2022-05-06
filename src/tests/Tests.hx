package tests;

import utest.Runner;

/**
	Class to run all tests
**/
class Tests {
    static function main() : Void {
        var runner = new Runner();
        new NoExitReport(runner);
        runner.addCases(tests.cases);
        runner.run();
    }
}

/**
	Class to extend and customise behviour of default test runner report.
	(default report does not send exit code on non-sys js target)
**/
class NoExitReport extends utest.ui.text.PrintReport {
    override function complete(result:utest.ui.common.PackageResult) : Void {
        this.result = result;

        #if js
            js.html.Console.log(this.getResults());
        #elseif sys
        Sys.println(this.getResults());
        #end

        #if instrument
            instrument.coverage.Coverage.endCoverage();
        #end
        if (!result.stats.isOk) {
            #if sys
                Sys.exit(1);
            #elseif js
            js.Syntax.code("process.exit(1)");
            #end
        }
    }
}
