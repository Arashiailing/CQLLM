/**
 * @name Percentage of comments
 * @description Computes the comment density metric for Python files by comparing comment lines 
 *              against total lines. Docstrings are excluded from this calculation and tracked 
 *              as a separate metric.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python library for code analysis

// Retrieve Python modules and their corresponding metrics
from Module sourceFile, ModuleMetrics fileMetrics
where 
  fileMetrics = sourceFile.getMetrics() and  // Associate metrics with each module
  fileMetrics.getNumberOfLines() > 0  // Filter out empty modules
select 
  sourceFile, 
  100.0 * (fileMetrics.getNumberOfLinesOfComments().(float) / fileMetrics.getNumberOfLines().(float)) as commentRatio  // Calculate comment density
  order by commentRatio desc  // Rank results by highest comment density