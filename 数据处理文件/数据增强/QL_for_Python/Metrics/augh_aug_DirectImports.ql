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

// For each Python module entity, compute the count of its direct module imports
from ModuleValue moduleEntity, int directImportCount
where 
  // Compute the total number of modules that are directly imported by the current module
  directImportCount = count(ModuleValue importedModuleEntity | 
                           // Find all modules that are directly imported by moduleEntity
                           importedModuleEntity = moduleEntity.getAnImportedModule())
// Output the file scope (representing the file) along with its direct import count
select moduleEntity.getScope(), directImportCount