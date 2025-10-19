/**
 * @name Total Comment Lines Count in Python Source Files
 * @kind treemap
 * @description Aggregates and displays the total count of comment lines across Python source files,
 *              including both inline comments and documentation strings. The calculation excludes
 *              blank lines and lines containing only code without any commentary.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import the Python module for analyzing Python source code

// Process each Python module to determine its total comment line count
from Module pythonFile, int totalComments
where
  // Compute the sum of regular comment lines and docstring lines
  totalComments = pythonFile.getMetrics().getNumberOfLinesOfComments() + 
                  pythonFile.getMetrics().getNumberOfLinesOfDocStrings()
select pythonFile, totalComments order by totalComments desc // Output files with their respective comment line counts, sorted in descending order