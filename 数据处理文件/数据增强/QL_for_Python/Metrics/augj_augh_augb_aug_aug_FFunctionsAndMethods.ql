/**
 * @name Functions and methods per file
 * @description Provides a statistical breakdown of the number of functions and methods
 *              contained within each Python source file, excluding anonymous lambda functions.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// Analyze Python source files to calculate the total number of named functions and methods
// Lambda expressions are excluded from this count as they are anonymous functions typically
// used for short, inline operations rather than named reusable code blocks.
from Module sourceFile, int functionMethodTotal
where 
  // Compute the aggregate count by considering only those callable entities that:
  // 1. Are defined within the current source file being analyzed
  // 2. Have a proper name (i.e., not lambda expressions)
  functionMethodTotal = count(Function callableEntity | 
    callableEntity.getEnclosingModule() = sourceFile and 
    not callableEntity.getName().matches("lambda")
  )
// Present the analysis results with source files sorted in descending order
// based on their function and method count
select sourceFile, functionMethodTotal order by functionMethodTotal desc