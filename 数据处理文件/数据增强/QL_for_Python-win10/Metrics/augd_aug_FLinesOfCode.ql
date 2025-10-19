/**
 * @name File Code Line Count
 * @kind treemap
 * @description Computes the total lines of code per file, excluding lines containing
 *              only docstrings, comments, or whitespace characters.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Select file modules and their corresponding code line counts
from Module moduleFile, int codeLineCount
where 
  // Calculate actual code lines by excluding documentation and comments
  codeLineCount = moduleFile.getMetrics().getNumberOfLinesOfCode()
// Output results sorted by line count in descending order
select moduleFile, codeLineCount order by codeLineCount desc