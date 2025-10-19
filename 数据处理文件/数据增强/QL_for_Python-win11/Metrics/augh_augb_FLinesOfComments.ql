/**
 * @name Total Comment Lines Count in Python Source Files
 * @kind treemap
 * @description This query computes the aggregate count of comment lines across each Python file,
 *              including both standard comments and documentation strings. The calculation
 *              excludes blank lines and lines containing only code without comments.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import the Python module for analyzing Python source code

// Extract data from each module (file) and calculate the total lines of comments and docstrings
from Module pyModule, int totalCommentLines
where
  // Calculate the total comment lines by summing regular comments and docstrings
  totalCommentLines = pyModule.getMetrics().getNumberOfLinesOfComments() + 
                      pyModule.getMetrics().getNumberOfLinesOfDocStrings()
select pyModule, totalCommentLines order by totalCommentLines desc // Output modules with their total comment lines, sorted in descending order