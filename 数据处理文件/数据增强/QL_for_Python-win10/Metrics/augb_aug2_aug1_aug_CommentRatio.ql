/**
 * @name Python source file comment density analysis
 * @description Computes the percentage of comment lines relative to the total lines in Python source files.
 *              Note that this analysis specifically focuses on regular comments and excludes docstrings,
 *              which are treated as a distinct documentation element.
 * @kind treemap
 * @id py/comment-density-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module pythonFile
where pythonFile.getMetrics().getNumberOfLines() > 0
select pythonFile,
       100.0 * pythonFile.getMetrics().getNumberOfLinesOfComments() / pythonFile.getMetrics().getNumberOfLines() as commentRatio
order by commentRatio desc