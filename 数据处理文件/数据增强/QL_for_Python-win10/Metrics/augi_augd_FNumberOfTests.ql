/**
 * @name Number of tests
 * @description Computes the quantity of test functions present in every Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import necessary Python language support modules for static analysis
import python
// Import utilities specifically designed to filter and identify test-related code
import semmle.python.filters.Tests

// Declare variables: sourceModule refers to the Python file under examination,
// and testMethodCount denotes the total number of test methods found within it
from Module sourceModule, int testMethodCount
// Determine testMethodCount by accurately counting all test methods that belong to sourceModule
where testMethodCount = strictcount(Test singleTest | singleTest.getEnclosingModule() = sourceModule)
// Display the file path of each module alongside its corresponding test method count,
// with results arranged in descending order based on test count
select sourceModule.getFile(), testMethodCount order by testMethodCount desc