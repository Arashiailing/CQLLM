/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Calculates the total comment lines per file (including docstrings,
 *              excluding pure code lines and blank lines).
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import Python module for analyzing Python code structure

// For each Python file, calculate the combined count of comments and docstrings
from Module pythonFile, int totalCommentLines
where
  // Compute the total comment lines by summing regular comments and docstrings
  totalCommentLines = 
    pythonFile.getMetrics().getNumberOfLinesOfComments() + 
    pythonFile.getMetrics().getNumberOfLinesOfDocStrings()
select pythonFile, totalCommentLines order by totalCommentLines desc