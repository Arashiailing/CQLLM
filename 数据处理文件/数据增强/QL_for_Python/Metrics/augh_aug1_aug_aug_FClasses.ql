/**
 * @name Classes per file
 * @description Counts the number of class definitions in each Python source file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// For each Python module, determine how many classes are defined within it
from Module sourceFile, int numberOfClasses

// Compute the total class definitions per source file
where numberOfClasses = count(Class cls | cls.getEnclosingModule() = sourceFile)

// Display results: source file with its class count, sorted from highest to lowest count
select sourceFile, numberOfClasses order by numberOfClasses desc