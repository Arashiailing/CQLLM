/**
 * @name Test Method Count Analysis
 * @description Provides a quantitative analysis of test methods distributed across Python modules,
 *              enabling identification of test coverage patterns and potential areas needing additional testing.
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import core Python language analysis capabilities
import python
// Import specialized utilities for test case identification and filtering
import semmle.python.filters.Tests

// Main query implementation for analyzing test method distribution
from Module pyModule, int numberOfTests
where 
  // Compute the precise count of test methods contained within each Python module
  numberOfTests = strictcount(Test testCase | 
    // Establish relationship between test case and its containing module
    testCase.getEnclosingModule() = pyModule
  )
// Generate results showing module file path and corresponding test count,
// ordered by test count in descending order to highlight modules with highest test density
select pyModule.getFile(), numberOfTests order by numberOfTests desc