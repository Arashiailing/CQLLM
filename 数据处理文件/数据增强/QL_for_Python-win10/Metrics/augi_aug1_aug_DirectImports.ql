/**
 * @name Direct imports per file
 * @description Measures the count of modules directly imported by each Python file.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import the Python analysis framework to enable AST traversal and module dependency analysis
import python

// For each Python source module, determine the number of its direct dependencies
from ModuleValue sourceModule, int importCount
where 
  // Calculate the quantity of unique modules that are directly referenced by the source module
  importCount = count(ModuleValue dependency | 
                     dependency = sourceModule.getAnImportedModule())
// Display the module's file scope along with its count of direct imports
select sourceModule.getScope(), importCount