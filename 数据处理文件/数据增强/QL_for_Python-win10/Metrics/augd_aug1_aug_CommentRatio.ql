/**
 * @name Python source file comment density analysis
 * @description Measures the density of comment lines relative to total lines in Python source files.
 *              Note that docstrings are not included in this calculation and are processed independently.
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