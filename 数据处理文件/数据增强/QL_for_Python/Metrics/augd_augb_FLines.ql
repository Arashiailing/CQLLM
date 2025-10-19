/**
 * @name Python Module Line Count Analysis
 * @description Computes and displays the total line count for each Python module in the codebase.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python module for code analysis capabilities

// Define source variable representing Python modules
from Module pythonModule
// Filter modules that have line metrics available
where exists(pythonModule.getMetrics().getNumberOfLines())
// Output the module and its line count, sorted by line count in descending order
select pythonModule, pythonModule.getMetrics().getNumberOfLines() as totalLines 
order by totalLines desc