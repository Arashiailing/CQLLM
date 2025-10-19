/**
 * @name Percentage of comments
 * @description Calculates the ratio of comment lines to total lines in Python source files.
 *              This metric helps assess code documentation quality. Note: docstrings are
 *              excluded from this calculation and tracked separately.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python library for code analysis capabilities

// Select Python modules and their corresponding metrics
from Module pythonModule, ModuleMetrics moduleMetrics
// Ensure we only process modules with actual code content
where moduleMetrics = pythonModule.getMetrics() and moduleMetrics.getNumberOfLines() > 0
// Calculate the percentage of comment lines relative to total lines
select pythonModule, 
       100.0 * (moduleMetrics.getNumberOfLinesOfComments().(float) / moduleMetrics.getNumberOfLines().(float)) as commentPercentage
  // Present results in descending order of comment percentage
  order by commentPercentage desc