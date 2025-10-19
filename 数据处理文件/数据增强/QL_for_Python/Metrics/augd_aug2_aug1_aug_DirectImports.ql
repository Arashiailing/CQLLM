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
from ModuleValue currentModule, int importCount
where 
  // Count the number of unique modules directly imported by the current module
  importCount = count(ModuleValue importedModule | 
                   importedModule = currentModule.getAnImportedModule())
// Output the file scope along with its corresponding direct import count
select currentModule.getScope(), importCount