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

// For each Python module, compute the quantity of class declarations it contains
from Module sourceFile, int numClasses

// Determine the number of classes by counting all class definitions within the same module
where numClasses = count(Class cls | cls.getEnclosingModule() = sourceFile)

// Display the module along with its class count, sorted from highest to lowest count
select sourceFile, numClasses order by numClasses desc