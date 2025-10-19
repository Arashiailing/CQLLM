/**
 * @name Percentage of docstrings
 * @description Calculates the proportion of lines in a Python file that are dedicated to docstrings.
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
from Module sourceFile, ModuleMetrics fileMetrics
where 
  fileMetrics = sourceFile.getMetrics() and
  fileMetrics.getNumberOfLines() > 0
select sourceFile,
  // Calculate the percentage of lines that contain docstrings in the file
  (100.0 * fileMetrics.getNumberOfLinesOfDocStrings().(float) / fileMetrics.getNumberOfLines().(float)) as docstringPercentage
order by docstringPercentage desc