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

// Examine each Python source file to count the number of class declarations
from Module sourceFile, int numClasses

// Determine how many classes are declared in each Python source file
where numClasses = count(Class cls | cls.getEnclosingModule() = sourceFile)

// Display results with each Python source file and its class count, sorted by count in descending order
select sourceFile, numClasses order by numClasses desc