/**
 * @name Comment Percentage Analysis
 * @description Calculates the ratio of comment lines to total lines in Python files. 
 *              This metric excludes docstrings, which are handled by a separate analysis.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python library for code analysis

// Extract metrics for all modules with at least one line of code
from Module pythonModule, ModuleMetrics moduleMetrics, int totalLines, int commentLines
where 
  moduleMetrics = pythonModule.getMetrics() and 
  totalLines = moduleMetrics.getNumberOfLines() and 
  totalLines > 0 and
  commentLines = moduleMetrics.getNumberOfLinesOfComments()
select 
  pythonModule, 
  100.0 * (commentLines.(float) / totalLines.(float)) as ratio  // Calculate and display comment ratio
order by 
  ratio desc  // Sort results in descending order by ratio