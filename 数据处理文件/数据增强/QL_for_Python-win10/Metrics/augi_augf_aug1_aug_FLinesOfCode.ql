/**
 * @name File Code Line Count
 * @kind treemap
 * @description Analyzes Python source files to count lines containing actual code,
 *              excluding documentation, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Define the source and metric variables for our analysis
from Module sourceModule, int codeLineCount
where 
  // Calculate the effective code lines by leveraging Python's built-in metrics
  // This count excludes docstrings, comments, and blank lines
  codeLineCount = sourceModule.getMetrics().getNumberOfLinesOfCode()
// Generate results showing each Python file with its code line count
// Results are sorted in descending order to highlight files with the most code
select sourceModule, codeLineCount order by codeLineCount desc