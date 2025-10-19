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

// Define the query to analyze test distribution across modules
from Module sourceModule, int testCount
// Establish the relationship between modules and their test method counts
where 
  // Count all test methods that belong to the current module
  testCount = strictcount(Test testCase | 
    testCase.getEnclosingModule() = sourceModule
  )
// Present results showing each module file and its test count,
// sorted from highest to lowest test count
select sourceModule.getFile(), testCount order by testCount desc