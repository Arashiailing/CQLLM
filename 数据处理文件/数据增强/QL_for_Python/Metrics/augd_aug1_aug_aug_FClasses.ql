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

// For each Python module, count the total number of class definitions it contains
from Module sourceFile, int numberOfClasses

// The count of classes is determined by finding all Class entities whose enclosing module is the current source file
where numberOfClasses = count(Class cls | cls.getEnclosingModule() = sourceFile)

// Present the results showing each source file along with its class count, sorted from highest to lowest count
select sourceFile, numberOfClasses order by numberOfClasses desc