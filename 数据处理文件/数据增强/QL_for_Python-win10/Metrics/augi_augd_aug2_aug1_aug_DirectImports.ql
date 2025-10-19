/**
 * @name Direct imports per file
 * @description Quantifies the number of modules directly imported by each Python source file.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import the Python analysis framework to enable AST traversal and module relationship analysis
import python

// For each Python source file, calculate its direct import dependencies
from ModuleValue sourceModule, int directImportCount
where 
  // Compute the count of unique modules that are directly imported by the source module
  directImportCount = count(ModuleValue dependencyModule | 
                        dependencyModule = sourceModule.getAnImportedModule())
// Display the file scope along with its corresponding direct import count
select sourceModule.getScope(), directImportCount