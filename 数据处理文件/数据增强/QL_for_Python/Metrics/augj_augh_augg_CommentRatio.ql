/**
 * @name Percentage of comments
 * @description Calculates the comment density metric for Python source files by measuring 
 *              the ratio of comment lines to total lines. This metric excludes docstrings,
 *              which are tracked separately to provide a more accurate assessment of 
 *              code documentation quality.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python library for code analysis

// Extract Python modules and their associated metrics
from Module pythonModule, ModuleMetrics moduleMetrics
where 
  // Link each module with its corresponding metrics
  moduleMetrics = pythonModule.getMetrics() and
  // Exclude empty modules from the analysis
  moduleMetrics.getNumberOfLines() > 0
select 
  pythonModule, 
  // Compute comment density as a percentage
  100.0 * (moduleMetrics.getNumberOfLinesOfComments().(float) / moduleMetrics.getNumberOfLines().(float)) as commentDensity
order by commentDensity desc  // Sort results by highest comment density