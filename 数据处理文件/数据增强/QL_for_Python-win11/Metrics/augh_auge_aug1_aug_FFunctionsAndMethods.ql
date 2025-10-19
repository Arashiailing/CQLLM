/**
 * @name File-level function and method count
 * @description Analyzes Python modules by quantifying the number of user-defined
 *              functions and methods, with lambda expressions excluded from the count.
 *              This metric serves as an indicator of module complexity, helping to
 *              identify files that may require refactoring due to excessive function definitions.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// Iterate through all Python modules, calculating the total count of functions and methods defined in each
from Module moduleObj, int funcCount
// Calculation logic: count all named function definitions in the module, excluding lambda expressions
where funcCount = count(Function funcDef | 
       // Ensure the function definition belongs to the module being analyzed
       funcDef.getEnclosingModule() = moduleObj and 
       // Filter out lambda expressions, keeping only named functions
       funcDef.getName() != "lambda")
// Output results: module objects and their corresponding function counts, ordered by function count in descending order
select moduleObj, funcCount order by funcCount desc