/**
 * @name Test Method Count
 * @description Computes the total number of test functions present in each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language analysis capabilities
import python
// Import test case identification utilities
import semmle.python.filters.Tests

// Define the main query to count test methods per module
from Module pyModule, int numTests
where 
  // Compute the precise count of test methods in each module
  numTests = strictcount(Test testCase | 
    testCase.getEnclosingModule() = pyModule
  )
// Return the module file and its test count, sorted by count (descending)
select pyModule.getFile(), numTests order by numTests desc