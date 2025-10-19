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

// Import the Python analysis framework for AST traversal and module analysis
import python

// For each Python module, determine its direct import count
from ModuleValue sourceModule, int moduleImportCount
where 
  // Count the number of unique modules directly imported by the source module
  moduleImportCount = count(ModuleValue targetModule | 
                          targetModule = sourceModule.getAnImportedModule())
// Output the file scope along with its corresponding direct import count
select sourceModule.getScope(), moduleImportCount