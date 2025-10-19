/**
 * @name Classes per file
 * @description Statistical analysis of class definitions distribution across Python source files
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// Examine each Python source file to quantify the number of class definitions
from Module sourceFile, int numClasses

// Compute the total count of class definitions within each Python module
where numClasses = count(Class classDefinition | 
        classDefinition.getEnclosingModule() = sourceFile
    )

// Display results mapping each Python module to its class definition count,
// sorted in descending order based on the count
select sourceFile, numClasses order by numClasses desc