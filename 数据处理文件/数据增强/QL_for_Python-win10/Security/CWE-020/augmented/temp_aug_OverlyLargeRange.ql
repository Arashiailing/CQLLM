/**
 * @name Excessively large range iteration
 * @description Iterating over an extremely large range may cause performance degradation or resource exhaustion
 * @kind problem
 * @id python/augmented/overly-large-range
 * @problem.severity warning
 * @tags security
 *       external/cwe/cwe-020
 */

import python

class ExcessiveRangeCall extends Call {
    ExcessiveRangeCall() {
        exists(string funcName | 
            this.getFunc().(Name).getId() = "range" and
            (
                // Single argument case: range(stop)
                this.getNumArg() = 1 and
                exists(int stop | 
                    this.getArg(0).getValue().(IntValue).getIntValue() = stop and
                    stop > 1000000
                )
                or
                // Two argument case: range(start, stop)
                this.getNumArg() = 2 and
                exists(int start, int stop | 
                    this.getArg(0).getValue().(IntValue).getIntValue() = start and
                    this.getArg(1).getValue().(IntValue).getIntValue() = stop and
                    stop - start > 1000000
                )
            )
        )
    }
}

class ForLoopWithExcessiveRange extends For {
    ForLoopWithExcessiveRange() {
        this.getIter() instanceof ExcessiveRangeCall
    }
}

from ForLoopWithExcessiveRange problematicLoop
select problematicLoop, 
    "This loop iterates over an excessively large range, potentially causing performance issues or resource exhaustion."