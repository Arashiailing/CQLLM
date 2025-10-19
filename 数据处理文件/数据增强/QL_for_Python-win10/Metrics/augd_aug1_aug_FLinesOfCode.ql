/**
 * @name File Code Line Count
 * @kind treemap
 * @description Computes the effective lines of code for each Python file (excluding
 *              lines that only contain docstrings, comments, or whitespace).
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Identifies Python source files and computes their effective code line counts,
// excluding documentation, comments, and whitespace-only lines
from Module srcFile, int locCount
where 
  // For each source file, determine the number of lines containing actual code
  locCount = srcFile.getMetrics().getNumberOfLinesOfCode()
// Return the source files and their corresponding code line counts,
// sorted in descending order by line count
select srcFile, locCount order by locCount desc