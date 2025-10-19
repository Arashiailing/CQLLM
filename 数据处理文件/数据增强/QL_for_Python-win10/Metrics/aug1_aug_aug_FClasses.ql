/**
 * @name Classes per file
 * @description Analyzes and counts the number of classes defined in each source file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// Identify each source file and determine the count of classes it contains
from Module fileModule, int classCount

// Calculate the total number of classes defined within each source file
where classCount = count(Class classDef | classDef.getEnclosingModule() = fileModule)

// Output the results: file module and corresponding class count, ordered by class count in descending order
select fileModule, classCount order by classCount desc