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

// For each Python source file, calculate the total number of class definitions
from Module sourceFile, int numberOfClasses

// The count is determined by tallying all classes whose enclosing module matches the current source file
where numberOfClasses = count(Class cls | cls.getEnclosingModule() = sourceFile)

// Return the source file and its class count, sorted by the highest number of classes first
select sourceFile, numberOfClasses order by numberOfClasses desc