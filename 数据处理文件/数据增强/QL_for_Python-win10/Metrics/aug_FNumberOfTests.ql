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
from Module moduleObj, int testCount
where 
  // Calculate the exact number of test methods in each module
  testCount = strictcount(Test testMethod | 
    testMethod.getEnclosingModule() = moduleObj
  )
// Return the module file and its test count, sorted by count (descending)
select moduleObj.getFile(), testCount order by testCount desc