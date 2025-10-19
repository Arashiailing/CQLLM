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

// For each Python source file, compute its effective code lines
from Module sourceFile, int codeLines
where 
  // Calculate the number of lines containing actual code, excluding documentation and comments
  codeLines = sourceFile.getMetrics().getNumberOfLinesOfCode()
// Display the file modules and their respective line counts, sorted from highest to lowest
select sourceFile, codeLines order by codeLines desc