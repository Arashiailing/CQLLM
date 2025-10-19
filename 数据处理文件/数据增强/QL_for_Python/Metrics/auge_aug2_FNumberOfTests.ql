/**
 * @name Test Method Count
 * @description Counts the number of test methods within each Python module to assess test coverage
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import base Python language support
import python
// Import testing framework detection utilities
import semmle.python.filters.Tests

// Define variables for module and test count
from Module moduleContainer
// Generate output showing file path and test count, sorted from highest to lowest
select moduleContainer.getFile(), 
       strictcount(Test testMethod | testMethod.getEnclosingModule() = moduleContainer) as numberOfTests
order by numberOfTests desc