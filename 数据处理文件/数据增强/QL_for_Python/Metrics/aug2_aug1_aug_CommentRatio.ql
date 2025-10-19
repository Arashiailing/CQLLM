/**
 * @name Python source file comment density analysis
 * @description Calculates the ratio of comment lines to total lines in Python files.
 *              This metric excludes docstrings, which are evaluated separately from regular comments.
 * @kind treemap
 * @id py/comment-density-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module sourceFile
where sourceFile.getMetrics().getNumberOfLines() > 0
select sourceFile,
       100.0 * sourceFile.getMetrics().getNumberOfLinesOfComments() / sourceFile.getMetrics().getNumberOfLines() as commentDensity
order by commentDensity desc