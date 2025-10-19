/**
 * @name Number of tests
 * @description The number of test methods defined in a module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language support for code analysis
import python
// Import test filtering capabilities to identify test methods
import semmle.python.filters.Tests

// Define the query to count test methods in each module
from Module moduleUnderTest, int numberOfTests
where 
  // Count all test methods that belong to the current module
  numberOfTests = strictcount(
    Test testMethod | 
    // Filter for test methods that belong to the current module
    testMethod.getEnclosingModule() = moduleUnderTest
  )
// Present results showing each module file and its test count,
// sorted from highest to lowest test count
select moduleUnderTest.getFile(), numberOfTests order by numberOfTests desc