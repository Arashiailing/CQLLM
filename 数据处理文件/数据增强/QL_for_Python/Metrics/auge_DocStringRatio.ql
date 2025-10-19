/**
 * @name Docstring Coverage Ratio
 * @description Calculates the ratio of lines containing docstrings to total lines in a Python file.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Selects modules and their metrics where the module has more than zero lines
from Module pythonModule, ModuleMetrics moduleMetrics
where 
  moduleMetrics = pythonModule.getMetrics() and 
  moduleMetrics.getNumberOfLines() > 0
select pythonModule,
  // Calculate the percentage of lines that contain docstrings, ordered from highest to lowest
  100.0 * (moduleMetrics.getNumberOfLinesOfDocStrings().(float) / 
           moduleMetrics.getNumberOfLines().(float)) as docstringPercentage
order by docstringPercentage desc