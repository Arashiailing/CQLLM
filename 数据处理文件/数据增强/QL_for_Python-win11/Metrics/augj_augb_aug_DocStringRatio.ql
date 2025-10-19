/**
 * @name Docstring Coverage Percentage
 * @description Calculates the percentage of lines that contain docstrings in each Python source file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Retrieve all Python modules along with their corresponding code metrics
from Module sourceModule, ModuleMetrics codeMetrics
where 
  // Establish relationship between module and its metrics
  codeMetrics = sourceModule.getMetrics() and 
  // Exclude modules that contain no actual code
  codeMetrics.getNumberOfLines() > 0
select sourceModule,
  // Compute documentation coverage as a percentage value
  100.0 * (codeMetrics.getNumberOfLinesOfDocStrings().(float) / codeMetrics.getNumberOfLines().(float)) as documentationRatio
order by documentationRatio desc