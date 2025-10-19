/**
 * @name Code Lines per File
 * @kind treemap
 * @description Counts the significant lines of code in each Python file,
 *              excluding docstrings, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// For every Python module, compute its meaningful line count
from Module pythonModule, int codeLineCount
where 
  // Compute the actual code lines, disregarding comments and whitespace
  codeLineCount = pythonModule.getMetrics().getNumberOfLinesOfCode()
// Display results sorted by line count in descending order
select pythonModule, codeLineCount order by codeLineCount desc