/**
 * @name Python source file comment density analysis
 * @description Calculates the ratio of comment lines to total lines in Python source files.
 *              This metric specifically considers standard code comments and deliberately
 *              excludes docstrings, which are handled as separate documentation entities.
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
where exists(sourceModule.getMetrics().getNumberOfLines()) and
      sourceModule.getMetrics().getNumberOfLines() > 0
select sourceModule,
       (100.0 * sourceModule.getMetrics().getNumberOfLinesOfComments()) / 
       sourceModule.getMetrics().getNumberOfLines() as commentPercentage
order by commentPercentage desc