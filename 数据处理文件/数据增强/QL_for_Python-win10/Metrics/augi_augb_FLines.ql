/**
 * @name File Line Count Analysis
 * @description Computes and displays the total line count for each Python module in the codebase.
 *              This analysis helps identify large files that might need refactoring.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python language support for CodeQL analysis

// Identify Python modules and calculate their corresponding line counts
from Module sourceModule, int totalLines
// Filter condition: totalLines should represent the actual number of lines in each module
where totalLines = sourceModule.getMetrics().getNumberOfLines()
// Generate results showing each module with its line count, ordered by size (largest first)
select sourceModule, totalLines order by totalLines desc