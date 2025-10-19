/**
 * @name Total comment lines per source file
 * @kind treemap
 * @description Computes the aggregate count of comment lines across each source file,
 *              including both standard comments and docstrings, while disregarding
 *              empty lines and lines containing only code.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import the Python module for source code analysis

// Extract data from each module (file) and calculate the combined count of comments and docstrings
from Module moduleFile, int totalCommentLines
where
  // Compute the total comment lines for each module (standard comments plus docstrings)
  totalCommentLines = moduleFile.getMetrics().getNumberOfLinesOfComments() + 
                      moduleFile.getMetrics().getNumberOfLinesOfDocStrings()
select moduleFile, totalCommentLines order by totalCommentLines desc // Output each module with its total comment count, sorted in descending order