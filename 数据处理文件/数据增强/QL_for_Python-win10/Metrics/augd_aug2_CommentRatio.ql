/**
 * @name Percentage of comments
 * @description Computes the proportion of comment lines versus total lines in Python source files.
 *              This indicator provides insight into code documentation practices. Note that 
 *              docstrings are not included in this computation and are analyzed independently.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python library for code analysis capabilities

// Query Python source modules and their associated metrics
from Module sourceModule, ModuleMetrics codeMetrics
// Filter to include only modules containing actual code content
where codeMetrics = sourceModule.getMetrics()
  and codeMetrics.getNumberOfLines() > 0
// Calculate the ratio of comment lines to total lines as a percentage
select sourceModule, 
       100.0 * (codeMetrics.getNumberOfLinesOfComments().(float) / codeMetrics.getNumberOfLines().(float)) as commentRatio
  // Sort results by comment ratio in descending order
  order by commentRatio desc