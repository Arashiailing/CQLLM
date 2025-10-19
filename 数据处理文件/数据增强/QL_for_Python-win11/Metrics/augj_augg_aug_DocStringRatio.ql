/**
 * @name Docstring Coverage Percentage
 * @description Calculates the percentage of lines that are docstrings in each Python file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Identify all Python source files with non-zero line count
from Module pyFile, ModuleMetrics fileMetrics
where 
  // Associate each Python file with its corresponding metrics
  fileMetrics = pyFile.getMetrics() and 
  // Filter out files that contain no code lines
  fileMetrics.getNumberOfLines() > 0
select pyFile,
  // Calculate docstring coverage ratio as percentage: (docstring lines / total lines) * 100
  100.0 * (fileMetrics.getNumberOfLinesOfDocStrings().(float) / fileMetrics.getNumberOfLines().(float)) as coveragePercentage
order by coveragePercentage desc