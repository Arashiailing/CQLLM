/**
 * @name Classes per file
 * @description Provides a statistical overview of class definitions across Python source files,
 *              helping identify files with high class density that may need refactoring.
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// For each Python module, determine the count of contained class definitions
from Module pyModule, int classCount

// Calculate the total number of classes defined within each module
where classCount = count(Class classDef | classDef.getEnclosingModule() = pyModule)

// Display modules and their class counts in descending order
select pyModule, classCount order by classCount desc