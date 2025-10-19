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

// For each Python module, calculate its direct import count
from ModuleValue importingModule, int directImportCount
where 
  // Count the number of unique modules directly imported by the importing module
  directImportCount = count(ModuleValue importedModule | 
                          importedModule = importingModule.getAnImportedModule())
// Output the file scope along with its corresponding direct import count
select importingModule.getScope(), directImportCount