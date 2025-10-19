/**
 * @name Python Module Line Count Analysis
 * @description Analyzes and presents the line count statistics for each Python module in the codebase.
 *              This query helps identify large files that might benefit from refactoring.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python module for code analysis capabilities

// Define source variables: Python modules and their corresponding line counts
from Module pyModule, int lineCount
// Filter modules to include only those with valid line count metrics
where lineCount = pyModule.getMetrics().getNumberOfLines() and lineCount > 0
// Output the module and its line count, sorted by line count in descending order
select pyModule, lineCount 
order by lineCount desc