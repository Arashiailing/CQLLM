/**
 * @name Direct imports per file
 * @description Quantifies the number of modules directly imported by each Python file.
 *              Higher values indicate tight coupling between modules, which can compromise
 *              modularity and make the codebase harder to maintain and refactor.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// This query utilizes the Python analysis framework to traverse the AST and examine module dependencies
import python

// For each Python module, compute the count of its direct module dependencies
from ModuleValue analyzedModule, int directImportCount
where 
  // Determine the number of unique modules directly imported by the analyzed module
  directImportCount = count(ModuleValue importedModule | 
                         importedModule = analyzedModule.getAnImportedModule())
// Output the module's scope along with its corresponding direct import count
select analyzedModule.getScope(), directImportCount