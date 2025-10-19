/**
 * @name Test methods count
 * @description Calculates the number of test functions present in each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language analysis capabilities
import python
// Import utilities for identifying and filtering test code
import semmle.python.filters.Tests

// Primary query to determine test method count per module
from Module moduleObj, int numTestMethods
where 
  // Calculate the exact quantity of test methods in each module
  numTestMethods = strictcount(Test testMethod | 
    testMethod.getEnclosingModule() = moduleObj
  )
// Present module file path with corresponding test count, sorted by count in descending order
select moduleObj.getFile(), numTestMethods order by numTestMethods desc