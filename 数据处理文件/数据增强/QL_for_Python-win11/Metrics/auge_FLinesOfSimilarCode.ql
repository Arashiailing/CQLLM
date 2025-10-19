/**
 * @deprecated
 * @name Similar lines in files
 * @description The number of lines in a file, including code, comment and whitespace lines,
 *              which are similar in at least one other place.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python

// Define source variables for file analysis
from File targetFile, int similarityCount

// Apply unconditional filter (retains original logic)
where none()

// Select results with ordering
select targetFile, similarityCount 
order by similarityCount desc