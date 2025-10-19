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

// Source module represents each Python file to be analyzed
from Module sourceModule, ModuleMetrics moduleMetrics
where 
  // Associate metrics with the source module for analysis
  moduleMetrics = sourceModule.getMetrics() and 
  // Ensure the file contains at least one line to prevent division by zero
  moduleMetrics.getNumberOfLines() > 0
select sourceModule,
  // Calculate docstring coverage ratio as a percentage:
  // (number of docstring lines / total lines in file) * 100
  100.0 * (moduleMetrics.getNumberOfLinesOfDocStrings().(float) / moduleMetrics.getNumberOfLines().(float)) as docstringRatio
order by docstringRatio desc