/**
 * @name Python source code comment ratio evaluation
 * @description Calculates the ratio of comment lines to total lines in Python source files.
 *              This metric excludes docstrings from the calculation since they serve as
 *              documentation rather than inline code explanations.
 * @kind treemap
 * @id py/comment-density-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module sourceFile, int totalLines, int commentCount
where 
  totalLines = sourceFile.getMetrics().getNumberOfLines() and
  totalLines > 0 and
  commentCount = sourceFile.getMetrics().getNumberOfLinesOfComments()
select sourceFile,
       (100.0 * commentCount) / totalLines as commentPercentage
order by commentPercentage desc