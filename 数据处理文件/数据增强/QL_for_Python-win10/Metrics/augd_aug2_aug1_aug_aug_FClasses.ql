/**
 * @name Classes per file
 * @description Analyzes the distribution of class definitions across Python source files.
 *              This statistical overview helps identify files with high class density,
 *              which may indicate opportunities for refactoring or architectural improvements.
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// Iterate through each Python module to analyze its class definition count
from Module moduleFile, int classCount

// Calculate the total number of class declarations contained within each module
// by aggregating all class definitions that share the same enclosing module
where classCount = count(Class classDef | classDef.getEnclosingModule() = moduleFile)

// Output the results displaying each module alongside its class count,
// sorted in descending order to highlight files with the highest class density
select moduleFile, classCount order by classCount desc