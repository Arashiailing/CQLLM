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
from Module pythonModule, ModuleMetrics fileMetrics
where 
  // Establish relationship between module and its metrics
  fileMetrics = pythonModule.getMetrics()
  // Ensure the module contains at least one line of code
  and fileMetrics.getNumberOfLines() > 0
select pythonModule,
  // Calculate documentation coverage as a percentage: (docstring lines / total lines) * 100
  100.0 * (fileMetrics.getNumberOfLinesOfDocStrings().(float) / fileMetrics.getNumberOfLines().(float)) as documentationCoverage
order by documentationCoverage desc