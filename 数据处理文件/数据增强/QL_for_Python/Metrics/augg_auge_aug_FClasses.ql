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

// Identify Python modules and their corresponding class counts
from Module fileModule, int classCount
// Compute the total number of classes defined within each module
where classCount = count(Class classDef | classDef.getEnclosingModule() = fileModule)
// Present results sorted by class count in descending order for easier analysis
select fileModule, classCount order by classCount desc