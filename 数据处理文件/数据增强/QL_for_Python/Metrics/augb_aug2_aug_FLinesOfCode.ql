/**
 * @name Code Line Count by File
 * @kind treemap
 * @description Computes the effective number of code lines per Python file,
 *              not counting lines that solely contain docstrings, comments,
 *              or whitespace characters.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Iterate through each Python module and calculate its effective code line count
from Module pythonModule
// Output modules with their effective line counts in descending order
select pythonModule, pythonModule.getMetrics().getNumberOfLinesOfCode() as effectiveLineCount 
order by effectiveLineCount desc