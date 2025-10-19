/**
 * @name Direct imports per file
 * @description The number of modules directly imported by this file.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import Python analysis library to enable code parsing and AST traversal
import python

// For each Python module, determine its direct import count
from ModuleValue moduleVal, int importCount
where 
  // Calculate the number of modules directly imported by the current module
  importCount = count(ModuleValue importedModule | 
                     importedModule = moduleVal.getAnImportedModule())
// Output the file scope and its corresponding direct import count
select moduleVal.getScope(), importCount