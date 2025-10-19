/**
 * @name Documentation coverage ratio
 * @description Calculates the percentage of lines in a Python file that are dedicated to docstrings.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Select Python modules and their metrics, filtering out empty files
from Module moduleObj, ModuleMetrics moduleMetric
where 
  moduleMetric = moduleObj.getMetrics() and 
  moduleMetric.getNumberOfLines() > 0
select 
  moduleObj,
  // Compute docstring coverage as a percentage of total lines
  100.0 * 
    (moduleMetric.getNumberOfLinesOfDocStrings().(float) / 
     moduleMetric.getNumberOfLines().(float)) as docstringPercentage
order by 
  docstringPercentage desc