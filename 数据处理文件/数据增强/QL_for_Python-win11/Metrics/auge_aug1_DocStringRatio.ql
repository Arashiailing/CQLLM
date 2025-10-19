/**
 * @name Documentation coverage ratio
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

// Identify Python modules with their corresponding metrics, excluding empty files
from Module pyModule, ModuleMetrics moduleStats
where 
  moduleStats = pyModule.getMetrics() and 
  moduleStats.getNumberOfLines() > 0
select 
  pyModule,
  // Calculate the docstring coverage percentage relative to total lines
  100.0 * 
    (moduleStats.getNumberOfLinesOfDocStrings().(float) / 
     moduleStats.getNumberOfLines().(float)) as docCoverageRatio
order by 
  docCoverageRatio desc