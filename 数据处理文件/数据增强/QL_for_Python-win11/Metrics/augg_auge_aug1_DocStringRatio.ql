/**
 * @name Documentation coverage ratio
 * @description Computes the percentage of docstring lines compared to the total lines in Python source files.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Analyze Python files along with their metrics, filtering out empty files
from Module pythonFile, ModuleMetrics fileMetrics
where 
  fileMetrics = pythonFile.getMetrics() and 
  fileMetrics.getNumberOfLines() > 0
select 
  pythonFile,
  // Compute the documentation coverage as a percentage of total lines
  (100.0 * 
    (fileMetrics.getNumberOfLinesOfDocStrings().(float) / 
     fileMetrics.getNumberOfLines().(float))) as documentationPercentage
order by 
  documentationPercentage desc