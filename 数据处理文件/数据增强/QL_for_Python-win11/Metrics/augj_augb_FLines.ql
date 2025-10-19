/**
 * @name File Line Count Analysis
 * @description Computes and displays the total line count for each Python file module.
 *              This analysis helps identify large files that might benefit from refactoring.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python module for code analysis capabilities

// Define source variables representing Python modules and their corresponding line counts
from Module pythonModule, int totalLines
// Calculate the total number of lines for each Python module
where totalLines = pythonModule.getMetrics().getNumberOfLines()
// Output the module and its line count, sorted by line count in descending order
select pythonModule, totalLines order by totalLines desc