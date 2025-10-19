/**
 * @name Number of tests
 * @description Calculates the count of test methods within each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language support for code analysis
import python
// Import test filtering utilities to identify test methods
import semmle.python.filters.Tests

// Define variables: targetModule represents the Python module being analyzed,
// and testCount represents the number of test methods in that module
from Module targetModule, int testCount
// Calculate testCount as the precise count of test methods where the enclosing module is targetModule
where testCount = strictcount(Test testCase | testCase.getEnclosingModule() = targetModule)
// Output the file path of each module along with its test count, sorted in descending order
select targetModule.getFile(), testCount order by testCount desc