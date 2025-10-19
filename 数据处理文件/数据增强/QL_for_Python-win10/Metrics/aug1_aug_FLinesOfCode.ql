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

// Query to identify Python source files and calculate their effective code line counts
from Module sourceFile, int codeLineCount
where 
  // For each source file, compute the number of lines containing actual code,
  // excluding documentation, comments, and whitespace-only lines
  codeLineCount = sourceFile.getMetrics().getNumberOfLinesOfCode()
// Return the source files and their corresponding code line counts,
// sorted in descending order by line count
select sourceFile, codeLineCount order by codeLineCount desc