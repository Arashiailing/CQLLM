/**
 * @name Documentation String Coverage Percentage
 * @description Measures the proportion of documentation strings relative to total code lines in Python files.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Find all Python source files that contain actual code
from Module sourceFile, ModuleMetrics codeMetrics
where 
  // Obtain statistical data about the current source file
  codeMetrics = sourceFile.getMetrics() and 
  // Filter out files with no content to avoid division by zero
  codeMetrics.getNumberOfLines() > 0
select sourceFile,
  // Compute documentation coverage: (documentation lines / total lines) * 100
  (100.0 * codeMetrics.getNumberOfLinesOfDocStrings().(float) / codeMetrics.getNumberOfLines().(float)) as docCoverage
order by docCoverage desc