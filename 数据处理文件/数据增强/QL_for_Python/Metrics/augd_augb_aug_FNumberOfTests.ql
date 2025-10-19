/**
 * @name Test methods count
 * @description Computes the quantity of test functions contained in each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import necessary Python language analysis framework
import python
// Import test detection and filtering utilities for identifying test functions
import semmle.python.filters.Tests

// Query to count test methods in each Python module
from Module sourceModule, int numberOfTests
where 
  // Calculate the exact number of test methods in each module
  numberOfTests = strictcount(Test testFunction | 
    testFunction.getEnclosingModule() = sourceModule
  )
// Select the module file path and its test count, sorted by count in descending order
select sourceModule.getFile(), numberOfTests order by numberOfTests desc