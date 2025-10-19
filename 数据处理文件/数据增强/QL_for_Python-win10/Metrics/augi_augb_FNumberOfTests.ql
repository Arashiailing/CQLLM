/**
 * @name Number of tests
 * @description Quantifies the distribution of test methods across Python modules
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

// Analyze test method distribution across Python modules
from Module moduleToAnalyze, int numberOfTests
// Establish correlation between modules and their respective test method quantities
where 
  // Calculate the total number of test methods contained within each module
  numberOfTests = strictcount(Test testMethod | 
    testMethod.getEnclosingModule() = moduleToAnalyze
  )
// Generate results displaying module files alongside their test method counts,
// ordered in descending sequence based on test method quantity
select moduleToAnalyze.getFile(), numberOfTests order by numberOfTests desc