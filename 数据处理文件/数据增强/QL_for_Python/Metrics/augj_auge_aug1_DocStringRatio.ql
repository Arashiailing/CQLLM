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

// Analyze Python source files to compute documentation coverage metrics
from Module sourceFile, ModuleMetrics fileMetrics
where 
  // Associate metrics with each module and exclude empty files
  fileMetrics = sourceFile.getMetrics() and 
  fileMetrics.getNumberOfLines() > 0
select 
  sourceFile,
  // Calculate documentation coverage percentage:
  // (docstring lines / total lines) * 100
  100.0 * 
    (fileMetrics.getNumberOfLinesOfDocStrings().(float) / 
     fileMetrics.getNumberOfLines().(float)) as documentationCoverage
order by 
  documentationCoverage desc