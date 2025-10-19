/**
 * @name Classes per file
 * @description Counts and displays the number of classes defined in each Python file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * This query helps identify files that might be too large or complex by counting
 * the number of classes they contain. Files with many classes may need refactoring.
 */

import python

// Define source module and its class count
from Module sourceModule, int numberOfClasses
// Calculate the number of classes within each module
where numberOfClasses = count(Class cls | cls.getEnclosingModule() = sourceModule)
// Output results ordered by class count in descending order
select sourceModule, numberOfClasses order by numberOfClasses desc