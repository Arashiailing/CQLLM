/**
 * @name Number of tests
 * @description Quantifies the total test methods contained within each Python module
 * @kind treemap
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/tests-in-files
 */

// Import Python language support library
import python
// Import specialized library for identifying test-related code
import semmle.python.filters.Tests

// Select module objects and their corresponding test counts
from Module sourceModule, int testCount
// Calculate the exact number of test methods in each module
where testCount = strictcount(Test testCase | testCase.getEnclosingModule() = sourceModule)
// Output the file path of each module along with its test count, sorted in descending order
select sourceModule.getFile(), testCount order by testCount desc