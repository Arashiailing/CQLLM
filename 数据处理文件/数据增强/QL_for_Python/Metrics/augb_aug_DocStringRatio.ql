/**
 * @name Docstring Coverage Percentage
 * @description Measures the ratio of docstring lines to total lines in each Python file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Query all non-empty Python modules and calculate their docstring coverage
from Module pythonModule, ModuleMetrics moduleMetrics
where 
  // Associate each module with its corresponding metrics
  moduleMetrics = pythonModule.getMetrics() and 
  // Filter out empty modules (modules with no lines of code)
  moduleMetrics.getNumberOfLines() > 0
select pythonModule,
  // Calculate docstring coverage as a percentage
  100.0 * (moduleMetrics.getNumberOfLinesOfDocStrings().(float) / moduleMetrics.getNumberOfLines().(float)) as docstringCoveragePercentage
order by docstringCoveragePercentage desc