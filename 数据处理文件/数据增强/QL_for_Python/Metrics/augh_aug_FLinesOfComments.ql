/**
 * @name Lines of comments in files
 * @kind treemap
 * @description Calculates the total number of comment lines in each Python file, 
 *              including both regular comments and docstrings. Lines containing only code 
 *              or blank lines are excluded from this count.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python

// For each Python module, calculate the total comment lines
// by summing regular comment lines and docstring lines
from Module pythonModule, int commentLineCount
where
  // The total comment count is the sum of regular comments and docstrings
  commentLineCount = 
    pythonModule.getMetrics().getNumberOfLinesOfComments() + 
    pythonModule.getMetrics().getNumberOfLinesOfDocStrings()
select pythonModule, commentLineCount order by commentLineCount desc