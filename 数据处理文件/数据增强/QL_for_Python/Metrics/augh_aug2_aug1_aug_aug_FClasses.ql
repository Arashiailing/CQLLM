/**
 * @name Classes per file
 * @description Statistical analysis of class distribution across Python source files
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// For each Python module, calculate and store its class definition count
from Module moduleFile, int classCount

// The class count is derived from all class definitions within the module
where classCount = count(Class classDef | classDef.getEnclosingModule() = moduleFile)

// Display results with modules having the most classes listed first
select moduleFile, classCount order by classCount desc