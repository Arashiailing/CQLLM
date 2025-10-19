/**
 * @name Documentation coverage ratio
 * @description Measures docstring coverage percentage in Python files (docstring lines / total lines).
 *              Higher percentages indicate better documentation. Empty files are excluded.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Analyze Python modules with non-zero line counts
from Module pyModule, ModuleMetrics metrics
where 
  // Ensure metrics correspond to the module and file has content
  metrics = pyModule.getMetrics() and 
  metrics.getNumberOfLines() > 0
select 
  pyModule,
  // Calculate documentation coverage percentage
  (100.0 * 
    (metrics.getNumberOfLinesOfDocStrings().(float) / 
     metrics.getNumberOfLines().(float))) as documentationPercentage
order by 
  documentationPercentage desc