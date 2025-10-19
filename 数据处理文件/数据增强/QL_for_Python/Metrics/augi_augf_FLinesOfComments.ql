/**
 * @name Lines of comments in files
 * @kind treemap
 * @description Computes aggregate comment line counts per Python file, including
 *              both inline comments and docstrings, while excluding code lines and whitespace.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python

// Select Python modules and calculate their total comment metrics
from Module sourceFile, int commentCount
where
  // Decompose comment calculation into distinct components
  commentCount = 
    sourceFile.getMetrics().getNumberOfLinesOfComments() + 
    sourceFile.getMetrics().getNumberOfLinesOfDocStrings()
select sourceFile, commentCount order by commentCount desc