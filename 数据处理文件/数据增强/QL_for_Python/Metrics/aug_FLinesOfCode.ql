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

// Define the query to select file modules and calculate their line counts
from Module fileModule, int lineCount
where 
  // Retrieve the count of actual code lines, excluding documentation and comments
  lineCount = fileModule.getMetrics().getNumberOfLinesOfCode()
// Output the file modules and their line counts, sorted in descending order
select fileModule, lineCount order by lineCount desc