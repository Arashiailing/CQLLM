/**
 * @name Python File Comment Analysis
 * @kind treemap
 * @description Counts total comment lines in Python source files, including both
 *              inline comments and docstrings. Excludes pure code lines and empty lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python

// Analyze each Python source file and calculate its total comment count
from Module sourceFile, int commentCount
where
  // Compute total comment count by combining regular comments and docstring lines
  commentCount = 
    sourceFile.getMetrics().getNumberOfLinesOfComments() + 
    sourceFile.getMetrics().getNumberOfLinesOfDocStrings()
select sourceFile, commentCount order by commentCount desc