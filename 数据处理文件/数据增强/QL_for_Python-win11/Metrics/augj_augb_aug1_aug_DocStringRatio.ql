/**
 * @name Documentation String Coverage Percentage
 * @description Calculates the ratio of docstring lines to total lines in each Python file, expressed as a percentage.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Find all Python modules that contain source code
from Module sourceModule, ModuleMetrics moduleStats
where 
  // Link each module to its corresponding metrics
  moduleStats = sourceModule.getMetrics()
  // Filter out empty modules (those with no lines of code)
  and moduleStats.getNumberOfLines() > 0
select sourceModule,
  // Compute docstring coverage percentage: (docstring lines / total lines) * 100
  100.0 * (moduleStats.getNumberOfLinesOfDocStrings().(float) / moduleStats.getNumberOfLines().(float)) as documentationCoverage
order by documentationCoverage desc