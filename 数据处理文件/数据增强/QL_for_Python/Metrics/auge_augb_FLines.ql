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

// Select Python modules and their corresponding line counts directly
from Module pythonModule, int lineTotal
// Ensure the lineTotal variable accurately reflects the module's line count
where lineTotal = pythonModule.getMetrics().getNumberOfLines()
// Display results with modules sorted by line count in descending order
select pythonModule, lineTotal order by lineTotal desc