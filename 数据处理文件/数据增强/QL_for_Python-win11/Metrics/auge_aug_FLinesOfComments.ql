/**
 * @name Lines of comments in files
 * @kind treemap
 * @description Counts the total lines of comments in each Python file (including docstrings,
 *              while excluding lines containing only code or blank lines).
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import Python module for analyzing Python code structure

// Extract each Python module and calculate the combined count of comment and docstring lines
from Module pyModule, int commentLineCount
where
  // Compute the total comment lines for the file (including both regular comments and docstrings)
  commentLineCount = 
    pyModule.getMetrics().getNumberOfLinesOfComments() + 
    pyModule.getMetrics().getNumberOfLinesOfDocStrings()
select pyModule, commentLineCount order by commentLineCount desc