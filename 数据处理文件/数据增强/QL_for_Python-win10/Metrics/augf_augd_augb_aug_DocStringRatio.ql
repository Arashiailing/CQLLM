/**
 * @name Documentation Coverage Analysis
 * @description Measures the documentation quality by calculating the ratio of docstring lines 
 *              to total lines of code for each Python module. This helps identify modules 
 *              lacking proper documentation.
 * @kind treemap
 * @id py/doc-string-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

// Evaluate all Python modules along with their corresponding metrics data
from Module pythonModule, ModuleMetrics moduleMetrics
where 
  // Establish relationship between module and its metrics
  moduleMetrics = pythonModule.getMetrics() and 
  // Filter out empty modules to avoid division by zero
  moduleMetrics.getNumberOfLines() > 0
select pythonModule,
  // Calculate documentation coverage percentage: (docstring lines / total lines) * 100
  100.0 * (moduleMetrics.getNumberOfLinesOfDocStrings().(float) / moduleMetrics.getNumberOfLines().(float)) as documentationCoverage
order by documentationCoverage desc