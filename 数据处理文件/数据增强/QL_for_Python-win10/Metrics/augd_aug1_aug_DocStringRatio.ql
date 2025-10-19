/**
 * @name Documentation String Coverage Percentage
 * @description Calculates the percentage of lines dedicated to docstrings in each Python source file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Identify all Python modules containing source code
from Module pythonFile, ModuleMetrics fileMetrics
where 
  // Obtain metrics for the analyzed Python module
  fileMetrics = pythonFile.getMetrics() and 
  // Filter out empty files to avoid division by zero
  fileMetrics.getNumberOfLines() > 0
select pythonFile,
  // Compute docstring coverage percentage: (docstring lines / total code lines) * 100
  100.0 * (fileMetrics.getNumberOfLinesOfDocStrings().(float) / fileMetrics.getNumberOfLines().(float)) as docstringCoveragePercentage
order by docstringCoveragePercentage desc