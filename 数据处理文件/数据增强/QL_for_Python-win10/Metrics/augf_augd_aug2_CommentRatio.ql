/**
 * @name Percentage of comments
 * @description Measures the documentation density by calculating the percentage of comment lines
 *              relative to total lines in Python source files. This metric helps assess code
 *              maintainability through documentation practices. Docstrings are excluded from
 *              this analysis and are evaluated separately.
 * @kind treemap
 * @id py/comment-ratio-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python  // Import Python analysis library for source code processing

// Define variables to represent Python files and their corresponding metrics
from Module pyFile, ModuleMetrics metricsData
// Apply filtering conditions to ensure we only analyze valid Python modules
where metricsData = pyFile.getMetrics()  // Associate metrics with the source file
  and metricsData.getNumberOfLines() > 0  // Exclude empty files from analysis
// Compute the comment density ratio and present results
select pyFile, 
       // Calculate percentage: (comment lines / total lines) * 100
       100.0 * (metricsData.getNumberOfLinesOfComments().(float) / metricsData.getNumberOfLines().(float)) as commentRatio
  // Arrange output from highest to lowest comment density
  order by commentRatio desc