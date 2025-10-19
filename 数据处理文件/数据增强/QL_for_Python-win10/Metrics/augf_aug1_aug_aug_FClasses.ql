/**
 * @name Classes per file
 * @description This analysis quantifies the number of class definitions within each Python source file.
 *              It helps identify files with high class density, which may indicate potential
 *              refactoring opportunities or overly complex modules.
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// For each source module, determine the count of class definitions it contains
from Module sourceModule, int classDefinitionCount

// Compute the total number of classes defined within each source module
where classDefinitionCount = count(Class cls | cls.getEnclosingModule() = sourceModule)

// Present the analysis results: source module and its corresponding class count,
// arranged in descending order based on the number of classes
select sourceModule, classDefinitionCount order by classDefinitionCount desc