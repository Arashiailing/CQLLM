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

// Analyze all Python modules with their metrics data
from Module pyModule, ModuleMetrics metricsData
where 
  // Link each module to its corresponding metrics
  metricsData = pyModule.getMetrics() and 
  // Exclude modules with no lines of code
  metricsData.getNumberOfLines() > 0
select pyModule,
  // Compute the docstring coverage as a percentage
  100.0 * (metricsData.getNumberOfLinesOfDocStrings().(float) / metricsData.getNumberOfLines().(float)) as docstringRatio
order by docstringRatio desc