/**
 * @name Test methods count
 * @description Computes the quantity of test functions contained in each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language analysis capabilities
import python
// Import utilities for test detection and filtering
import semmle.python.filters.Tests

// Main query for counting test methods per module
from Module pythonModule, int testMethodCount
where 
  // Determine the precise count of test methods within each module
  testMethodCount = strictcount(Test testCase | 
    testCase.getEnclosingModule() = pythonModule
  )
// Output module file path along with its test count, ordered by count in descending order
select pythonModule.getFile(), testMethodCount order by testMethodCount desc