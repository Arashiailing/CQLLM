/**
 * @name Docstring Coverage Percentage
 * @description Calculates the percentage of lines that are docstrings in each Python file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Identify all Python modules with associated metrics
from Module pythonModule, ModuleMetrics moduleMetrics
where 
  // Link each module to its corresponding metrics
  moduleMetrics = pythonModule.getMetrics() and 
  // Filter out empty modules (those with no lines of code)
  moduleMetrics.getNumberOfLines() > 0
select pythonModule,
  // Compute the docstring coverage as a percentage of total lines
  100.0 * (moduleMetrics.getNumberOfLinesOfDocStrings().(float) / moduleMetrics.getNumberOfLines().(float)) as docstringCoveragePercentage
order by docstringCoveragePercentage desc