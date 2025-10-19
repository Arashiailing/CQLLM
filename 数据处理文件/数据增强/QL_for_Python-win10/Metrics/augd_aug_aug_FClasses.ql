/**
 * @name Classes per file
 * @description Analyzes and counts the number of class definitions within each Python source file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// Identify each Python module (file) and calculate the total class definitions it contains
from Module fileModule, int classCount

// Compute the total number of classes defined in each source module
where classCount = count(Class pyClass | pyClass.getEnclosingModule() = fileModule)

// Output results: file module and corresponding class count, sorted in descending order by class count
select fileModule, classCount order by classCount desc