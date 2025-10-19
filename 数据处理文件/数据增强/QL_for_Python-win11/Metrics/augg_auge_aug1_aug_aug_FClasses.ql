/**
 * @name Classes per file
 * @description Provides a statistical overview of class definitions distribution across Python source files
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// For each Python module, determine the quantity of class definitions contained within
from Module pyModule, int numClasses
where numClasses = count(Class cls | cls.getEnclosingModule() = pyModule)

// Output the analysis results: each module with its class count, sorted from highest to lowest
select pyModule, numClasses order by numClasses desc