/**
 * @name Direct imports per file
 * @description Calculates and visualizes the number of modules directly imported by each Python file.
 *              This metric helps identify files with high coupling, which may impact modularity and maintainability.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import the Python analysis library to enable AST traversal and code analysis capabilities
import python

// For each Python module, compute the count of its direct module imports
from ModuleValue sourceModule, int importCount
where 
  // Calculate the total number of modules directly imported by the source module
  importCount = count(ModuleValue targetModule | 
                     // Identify all modules that are directly imported by sourceModule
                     targetModule = sourceModule.getAnImportedModule())
// Output the file scope (representing the file) along with its direct import count
select sourceModule.getScope(), importCount