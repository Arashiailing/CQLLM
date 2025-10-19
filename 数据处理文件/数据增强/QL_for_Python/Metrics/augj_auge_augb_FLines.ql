/**
 * @name Python File Line Count Analysis
 * @description Computes and displays the total line count for each Python file module in the codebase.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python module for code analysis capabilities

// Extract Python modules and calculate their respective line counts
from Module pyModule, int lineCount
// Associate each module with its line count by retrieving metrics
where lineCount = pyModule.getMetrics().getNumberOfLines()
// Output modules ordered by line count in descending order for easy identification of large files
select pyModule, lineCount order by lineCount desc