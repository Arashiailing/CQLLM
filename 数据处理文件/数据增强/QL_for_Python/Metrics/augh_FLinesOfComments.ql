/**
 * @name Lines of comments in files
 * @kind treemap
 * @description Counts the total lines of comments in each Python file, including both
 *              regular comments and docstrings, while excluding pure code lines and blank lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import the Python module for analyzing Python code

// For each Python module, calculate the total number of comment lines
from Module pyModule, int totalCommentLines
where
  // Sum up regular comment lines and docstring lines for the module
  totalCommentLines = pyModule.getMetrics().getNumberOfLinesOfComments() + 
                      pyModule.getMetrics().getNumberOfLinesOfDocStrings()
select pyModule, totalCommentLines order by totalCommentLines desc // Output modules and their comment counts, sorted in descending order