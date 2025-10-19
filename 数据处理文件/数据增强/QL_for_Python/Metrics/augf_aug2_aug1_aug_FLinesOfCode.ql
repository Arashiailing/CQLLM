/**
 * @name File Code Line Count
 * @kind treemap
 * @description Analyzes and reports the total effective lines of code in each Python source file.
 *              Effective lines exclude those containing only docstrings, comments, or whitespace,
 *              providing a more accurate measure of actual code complexity.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// For each Python source module, calculate its effective code line count
from Module sourceFile, int codeLineCount
where 
  // Compute the number of lines containing actual code by filtering out
  // documentation, comments, and whitespace-only lines
  codeLineCount = sourceFile.getMetrics().getNumberOfLinesOfCode()
// Output the results sorted by line count in descending order to highlight
// files with the highest code complexity for maintainability review
select sourceFile, codeLineCount order by codeLineCount desc