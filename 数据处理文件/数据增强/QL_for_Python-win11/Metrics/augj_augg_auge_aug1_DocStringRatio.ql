/**
 * @name Documentation coverage ratio
 * @description Evaluates the proportion of docstring lines relative to total lines in Python source files.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Process Python modules with their metrics, excluding empty files
from Module sourceModule, ModuleMetrics moduleStats
where 
  moduleStats = sourceModule.getMetrics() and 
  moduleStats.getNumberOfLines() > 0
select 
  sourceModule,
  // Calculate documentation coverage percentage: (docstring lines / total lines) * 100
  (100.0 * 
    (moduleStats.getNumberOfLinesOfDocStrings().(float) / 
     moduleStats.getNumberOfLines().(float))) as documentationPercentage
order by 
  documentationPercentage desc