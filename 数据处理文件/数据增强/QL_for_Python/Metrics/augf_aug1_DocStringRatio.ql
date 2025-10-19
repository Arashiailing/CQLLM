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

// Query Python modules along with their metrics, excluding files with no content
from Module pyModule, ModuleMetrics moduleStats
where 
  moduleStats = pyModule.getMetrics() and 
  moduleStats.getNumberOfLines() > 0
select 
  pyModule,
  // Calculate the docstring coverage percentage relative to the total line count
  (100.0 * moduleStats.getNumberOfLinesOfDocStrings().(float) / 
   moduleStats.getNumberOfLines().(float)) as docCoverageRatio
order by 
  docCoverageRatio desc