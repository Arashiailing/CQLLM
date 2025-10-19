/**
 * @name Documentation String Coverage Percentage
 * @description Calculates the ratio of docstring lines to total lines in each Python module, expressed as a percentage.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Select all Python modules that contain code
from Module pyModule, ModuleMetrics metrics
where 
  // Obtain the metrics associated with the current module
  metrics = pyModule.getMetrics() and 
  // Filter out modules with zero lines of code
  metrics.getNumberOfLines() > 0
select pyModule,
  // Compute the docstring coverage percentage: (number of docstring lines / total lines) * 100
  100.0 * (metrics.getNumberOfLinesOfDocStrings().(float) / metrics.getNumberOfLines().(float)) as coveragePercentage
order by coveragePercentage desc