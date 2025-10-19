/**
 * @name Python source file comment density analysis
 * @description This analysis measures the density of comments in Python source files by calculating
 *              the ratio of comment lines to total lines, expressed as a percentage. The analysis
 *              specifically excludes docstrings from the comment count, treating them as a separate
 *              documentation category distinct from regular code comments.
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
  // Filter out empty files to avoid division by zero
  sourceModule.getMetrics().getNumberOfLines() > 0
select 
  sourceModule,
  // Compute the comment density as a percentage of total lines
  (100.0 * sourceModule.getMetrics().getNumberOfLinesOfComments()) / sourceModule.getMetrics().getNumberOfLines() as commentDensityPercentage
order by 
  commentDensityPercentage desc