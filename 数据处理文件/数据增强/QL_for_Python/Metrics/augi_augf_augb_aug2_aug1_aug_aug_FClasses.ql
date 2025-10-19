/**
 * @name Classes per file
 * @description Provides statistical insights into how class definitions are distributed across Python source files
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// For each Python module, compute the quantity of class definitions contained within
from Module pythonModule, int classCount

// Determine class count by aggregating all class declarations found in the same module
where classCount = count(Class classDeclaration | classDeclaration.getEnclosingModule() = pythonModule)

// Output the module file along with its corresponding class count, sorted from highest to lowest
select pythonModule, classCount order by classCount desc