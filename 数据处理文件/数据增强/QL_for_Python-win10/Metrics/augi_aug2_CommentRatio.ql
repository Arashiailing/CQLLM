/**
 * @name Percentage of comments
 * @description Computes the ratio of comment lines to total lines in Python source files.
 *              This metric provides insight into code documentation practices. Note that 
 *              docstrings are excluded from this calculation and are evaluated separately.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python library for code analysis capabilities

// Define source modules and their corresponding code metrics
from Module sourceModule, ModuleMetrics codeMetrics
// Ensure we only process modules containing actual code content
where codeMetrics = sourceModule.getMetrics()
  and codeMetrics.getNumberOfLines() > 0
// Calculate and return the comment ratio as a percentage
select sourceModule, 
       100.0 * (codeMetrics.getNumberOfLinesOfComments().(float) / codeMetrics.getNumberOfLines().(float)) as commentRatio
  // Sort results by comment ratio in descending order
  order by commentRatio desc