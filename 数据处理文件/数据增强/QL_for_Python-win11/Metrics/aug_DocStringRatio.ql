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

// Query all non-empty Python modules and their metrics
from Module pyModule, ModuleMetrics metrics
where 
  // Obtain metrics data for the module
  metrics = pyModule.getMetrics() and 
  // Ensure module contains code lines (non-empty file)
  metrics.getNumberOfLines() > 0
select pyModule,
  // Calculate docstring coverage: ratio of docstring lines to total lines as percentage
  100.0 * (metrics.getNumberOfLinesOfDocStrings().(float) / metrics.getNumberOfLines().(float)) as docstringRatio
order by docstringRatio desc