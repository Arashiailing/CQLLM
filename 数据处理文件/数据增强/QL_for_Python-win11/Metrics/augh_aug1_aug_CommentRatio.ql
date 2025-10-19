/**
 * @name Python source file annotation density analysis
 * @description Calculates the ratio of comment lines to total lines in Python source files.
 *              This metric excludes docstrings, which are handled as a separate measure.
 * @kind treemap
 * @id py/comment-density-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module sourceModule
where 
  // Only consider non-empty files
  sourceModule.getMetrics().getNumberOfLines() > 0
select 
  sourceModule, 
  // Compute the percentage of lines that are comments
  (
    100.0 * 
    sourceModule.getMetrics().getNumberOfLinesOfComments()
  ) / (
    sourceModule.getMetrics().getNumberOfLines()
  ) as annotationDensity
order by 
  annotationDensity desc