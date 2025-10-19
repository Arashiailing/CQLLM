/**
 * @name Documentation String Coverage Percentage
 * @description Computes the percentage of lines that are docstrings in each Python file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Identify all Python modules with code content
from Module pyFile, ModuleMetrics moduleMetrics
where 
  // Retrieve metrics for the current module
  moduleMetrics = pyFile.getMetrics() and 
  // Exclude empty files from analysis
  moduleMetrics.getNumberOfLines() > 0
select pyFile,
  // Calculate docstring coverage as percentage: (docstring lines / total lines) * 100
  100.0 * (moduleMetrics.getNumberOfLinesOfDocStrings().(float) / moduleMetrics.getNumberOfLines().(float)) as docstringRatio
order by docstringRatio desc