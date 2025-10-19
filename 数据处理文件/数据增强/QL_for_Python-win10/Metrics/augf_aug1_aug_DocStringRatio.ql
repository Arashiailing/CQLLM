/**
 * @name Documentation String Coverage Percentage
 * @description Measures the proportion of lines dedicated to docstrings within each Python source file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Analyze Python modules containing actual code
from Module pythonModule, ModuleMetrics moduleStatistics
where 
  // Obtain statistical data for the current Python module
  moduleStatistics = pythonModule.getMetrics() and 
  // Filter out empty files to ensure meaningful analysis
  moduleStatistics.getNumberOfLines() > 0
select pythonModule,
  // Compute documentation coverage percentage: (docstring lines / total lines) * 100
  100.0 * (moduleStatistics.getNumberOfLinesOfDocStrings().(float) / moduleStatistics.getNumberOfLines().(float)) as documentationPercentage
order by documentationPercentage desc