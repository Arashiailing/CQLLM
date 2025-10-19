/**
 * @name File Code Line Count
 * @kind treemap
 * @description Calculates the total lines of code in each file (excluding lines that
 *              only contain docstrings, comments or whitespace).
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Select each Python module and compute its effective code line count
from Module sourceFile, int codeLineCount
where 
  // Obtain the count of non-trivial code lines (excluding comments/whitespace)
  codeLineCount = sourceFile.getMetrics().getNumberOfLinesOfCode()
// Output modules with their line counts in descending order
select sourceFile, codeLineCount order by codeLineCount desc