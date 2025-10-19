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

// For every Python module, calculate the total count of class definitions it contains
from Module pyModule, int classCount

// Compute the class count by aggregating all class declarations within the same module
where classCount = count(Class classDef | classDef.getEnclosingModule() = pyModule)

// Output the module and its corresponding class count, ordered by count in descending order
select pyModule, classCount order by classCount desc