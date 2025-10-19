/**
 * @name Percentage of comments
 * @description Calculates the ratio of comment lines to total lines in Python files. 
 *              Docstrings are excluded from this metric and reported separately.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python library for code analysis

// Select data from Module and ModuleMetrics to calculate comment ratio
from Module pyModule, ModuleMetrics moduleMetrics
where 
  moduleMetrics = pyModule.getMetrics() and  // Get metrics for each module
  moduleMetrics.getNumberOfLines() > 0  // Only consider modules with at least one line
select 
  pyModule, 
  100.0 * (moduleMetrics.getNumberOfLinesOfComments().(float) / moduleMetrics.getNumberOfLines().(float)) as ratio  // Calculate comment percentage
  order by ratio desc  // Sort results by percentage in descending order