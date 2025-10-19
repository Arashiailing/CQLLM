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

// Identify each Python source file and calculate the number of class definitions it contains
from Module sourceFile, int classDefinitionCount

// For each Python module, count all class definitions that are directly enclosed within it
where classDefinitionCount = count(Class classEntity | classEntity.getEnclosingModule() = sourceFile)

// Present the analysis results: display each source file along with its class count,
// sorted in descending order based on the number of classes
select sourceFile, classDefinitionCount order by classDefinitionCount desc