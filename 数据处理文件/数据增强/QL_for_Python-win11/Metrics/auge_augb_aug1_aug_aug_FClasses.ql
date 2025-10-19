/**
 * @name Classes per file
 * @description Provides a statistical overview of class definitions across Python source files
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// Analyze each Python module to determine the quantity of class definitions it contains
from Module pythonModule, int classCount

// Calculate the total number of classes defined within each Python module
where classCount = count(Class classDef | classDef.getEnclosingModule() = pythonModule)

// Output results showing each Python module and its corresponding class count, ordered by count in descending order
select pythonModule, classCount order by classCount desc