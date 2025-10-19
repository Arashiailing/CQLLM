/**
 * @name Classes per file
 * @description Analyzes Python files to count the number of class definitions in each file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * This metric identifies potentially oversized or complex Python files by counting
 * their class definitions. Files with excessive class counts may benefit from refactoring
 * to improve maintainability and code organization.
 */

import python

// Define source module and the count of its class definitions
from Module sourceModule, int numberOfClasses
// Calculate how many classes are defined in each Python source file
where numberOfClasses = count(Class cls | cls.getEnclosingModule() = sourceModule)
// Output results with modules ordered by their class count in descending order
select sourceModule, numberOfClasses order by numberOfClasses desc