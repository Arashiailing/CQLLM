/**
 * @name File Line Count Analysis
 * @description Calculates the total number of lines in each Python file module.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python module for code analysis capabilities

// Define source variables representing Python modules and their corresponding line counts
from Module pyModule, int lineCount
// Establish the relationship where lineCount equals the number of lines in the module
where lineCount = pyModule.getMetrics().getNumberOfLines()
// Output the module and its line count, sorted by line count in descending order
select pyModule, lineCount order by lineCount desc