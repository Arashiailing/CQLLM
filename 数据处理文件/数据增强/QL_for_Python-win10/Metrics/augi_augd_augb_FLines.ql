/**
 * @name Python Module Line Count Analysis
 * @description Analyzes and presents the total number of lines for each Python module in the codebase.
 *              This query helps identify large files that might need refactoring or further investigation.
 * @kind treemap
 * @id py/lines-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python module for code analysis capabilities

// Source: All Python modules in the codebase
from Module sourceFile

// Filter: Only include modules that have line metrics available
where exists(sourceFile.getMetrics().getNumberOfLines())

// Output: Module and its line count, sorted by line count in descending order
select sourceFile, sourceFile.getMetrics().getNumberOfLines() as totalLines 
order by totalLines desc