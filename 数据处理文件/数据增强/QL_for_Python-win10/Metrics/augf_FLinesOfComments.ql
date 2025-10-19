/**
 * @name Lines of comments in files
 * @kind treemap
 * @description Calculates the total comment lines across Python files, encompassing both
 *              standard comments and docstrings, while excluding pure code lines and blank spaces.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import the Python module for analyzing Python source code

// Select each Python module and compute its total comment lines (comments + docstrings)
from Module fileModule, int totalCommentLines
where
  // Calculate the sum of comment lines and docstring lines for the module
  totalCommentLines = 
    fileModule.getMetrics().getNumberOfLinesOfComments() + 
    fileModule.getMetrics().getNumberOfLinesOfDocStrings()
select fileModule, totalCommentLines order by totalCommentLines desc // Return modules with their comment counts, sorted in descending order