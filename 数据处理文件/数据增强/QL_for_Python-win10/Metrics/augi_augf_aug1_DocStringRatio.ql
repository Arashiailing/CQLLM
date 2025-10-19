/**
 * @name Docstring line coverage percentage
 * @description Measures the ratio of docstring lines to total lines in Python source files.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Retrieve Python modules with their metrics, filtering out empty files
from Module sourceModule, ModuleMetrics metricsData
where 
  metricsData = sourceModule.getMetrics() 
  and metricsData.getNumberOfLines() > 0
select 
  sourceModule,
  // Compute docstring coverage percentage as ratio of docstring lines to total lines
  (100.0 * 
   metricsData.getNumberOfLinesOfDocStrings().(float) / 
   metricsData.getNumberOfLines().(float)) as docstringCoveragePercentage
order by 
  docstringCoveragePercentage desc