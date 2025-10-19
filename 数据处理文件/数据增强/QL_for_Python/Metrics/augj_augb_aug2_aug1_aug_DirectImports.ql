/**
 * @name Direct imports per file
 * @description Quantifies the number of modules directly imported by each Python file.
 *              Elevated counts may suggest excessive coupling, potentially compromising
 *              modularity and maintainability of the codebase.
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
from ModuleValue sourceFileModule, int importCount
where 
  // Calculate unique modules directly imported by the current file
  importCount = count(ModuleValue importedModule | 
                    importedModule = sourceFileModule.getAnImportedModule())
// Output file scope and its corresponding direct import count
select sourceFileModule.getScope(), importCount