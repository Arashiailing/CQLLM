/**
 * @name Percentage of comments
 * @description Quantifies code documentation coverage by computing the ratio of comment lines
 *              to total lines in Python source files. This metric serves as an indicator for
 *              code maintainability through consistent documentation practices. Note that
 *              docstrings are intentionally excluded from this calculation and are assessed
 *              through separate metrics.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python analysis library for source code processing

// Establish relationship between Python source modules and their corresponding metrics
from Module sourceModule, ModuleMetrics fileMetrics
// Apply validation filters to ensure meaningful analysis of non-empty Python files
where fileMetrics = sourceModule.getMetrics()  // Bind metrics data to the source module
  and fileMetrics.getNumberOfLines() > 0  // Filter out empty files to avoid division by zero
// Calculate and present the documentation density metric
select sourceModule, 
       // Compute documentation density: (comment lines / total lines) * 100
       100.0 * (fileMetrics.getNumberOfLinesOfComments().(float) / fileMetrics.getNumberOfLines().(float)) as documentationDensity
  // Sort results in descending order to highlight files with highest documentation density
  order by documentationDensity desc