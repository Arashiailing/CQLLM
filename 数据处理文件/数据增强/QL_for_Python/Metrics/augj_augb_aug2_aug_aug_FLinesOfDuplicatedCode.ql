/**
 * @deprecated  // This query has been deprecated, updated alternatives are recommended
 * @name File Line Duplication Analysis  // Query name: Analysis of duplicate lines in files
 * @description Computes and quantifies duplicate lines across files in the codebase,
 *              including code, comments, and whitespace.  // Functionality: Calculate and measure duplicate lines in each file throughout the codebase
 * @kind treemap  // Visualization type: TreeMap
 * @treemap.warnOn highValues  // High value warning configuration
 * @metricType file  // Metric type: File-level measurement
 * @metricAggregate avg sum max  // Aggregation methods: Average, sum, maximum
 * @tags testability  // Applicable tags: Testability-related
 * @id py/duplicated-lines-in-files  // Query identifier: py/duplicated-lines-in-files
 */

import python  // Import Python code analysis module

// Main query logic: Identify source files containing duplicate lines and calculate the count
from File analyzedFile, int duplicateLineCount
where 
  // Placeholder for query conditions (preserving original query structure)
  none()
// Output results: Source files and their corresponding duplicate line counts, ordered by count in descending order
select analyzedFile, duplicateLineCount order by duplicateLineCount desc