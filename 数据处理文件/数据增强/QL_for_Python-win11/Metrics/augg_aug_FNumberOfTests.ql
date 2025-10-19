/**
 * @name Number of tests
 * @description Calculates the count of test methods within each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language support
import python
// Import utilities for identifying test cases
import semmle.python.filters.Tests

// Define the main query to count test methods per module
from Module sourceModule, int testMethodCount
where 
  // For each module, calculate the total number of test methods it contains
  testMethodCount = strictcount(Test testCase | 
    testCase.getEnclosingModule() = sourceModule
  )
// Return the module file and its test count, sorted by count (descending)
select sourceModule.getFile(), testMethodCount order by testMethodCount desc