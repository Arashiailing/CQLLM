/**
 * @name Classes per file
 * @description Statistical analysis showing the distribution of class definitions in Python source files
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// For each Python source file, determine the total number of class definitions
from Module sourceFile, int classDefinitionCount

// Calculate the number of classes by tallying all class declarations within the same Python file
where classDefinitionCount = count(Class declaredClass | declaredClass.getEnclosingModule() = sourceFile)

// Display the source file along with its class count, sorted in descending order based on the count
select sourceFile, classDefinitionCount order by classDefinitionCount desc