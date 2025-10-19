/**
 * @name Documentation coverage ratio
 * @description Calculates the percentage of docstring lines relative to total lines in Python source files.
 *              Higher values indicate better documentation coverage. Empty files are excluded from analysis.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Analyze Python modules with their metrics, excluding empty files
from Module sourceModule, ModuleMetrics moduleMetrics
where 
  moduleMetrics = sourceModule.getMetrics() and 
  moduleMetrics.getNumberOfLines() > 0
select 
  sourceModule,
  // Compute documentation coverage: (docstring lines / total lines) * 100
  (100.0 * 
    (moduleMetrics.getNumberOfLinesOfDocStrings().(float) / 
     moduleMetrics.getNumberOfLines().(float))) as documentationPercentage
order by 
  documentationPercentage desc