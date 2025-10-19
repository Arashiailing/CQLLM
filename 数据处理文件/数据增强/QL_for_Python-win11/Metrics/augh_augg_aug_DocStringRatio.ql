/**
 * @name Docstring Coverage Percentage
 * @description Measures the documentation quality by calculating the ratio of docstring lines to total lines in Python files.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Find all Python modules and their associated metrics
from Module pyModule, ModuleMetrics moduleStats
where 
  // Establish relationship between module and its metrics
  moduleStats = pyModule.getMetrics() and 
  // Exclude modules with no code lines
  moduleStats.getNumberOfLines() > 0
select pyModule,
  // Calculate docstring coverage percentage: (docstring lines / total lines) * 100
  100.0 * (moduleStats.getNumberOfLinesOfDocStrings().(float) / moduleStats.getNumberOfLines().(float)) as docstringRatio
order by docstringRatio desc