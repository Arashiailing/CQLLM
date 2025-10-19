/**
 * @name Test methods count
 * @description Quantifies the number of test functions within each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language analysis framework
import python
// Import utilities for detecting and filtering test functions
import semmle.python.filters.Tests

// Query to calculate the quantity of test methods in each Python module
from Module pythonModule, int testCount
where 
  // Determine the count of test functions for each module
  testCount = strictcount(Test testCase | 
    testCase.getEnclosingModule() = pythonModule
  )
// Select the module file path and its test count, ordered by count in descending order
select pythonModule.getFile(), testCount order by testCount desc