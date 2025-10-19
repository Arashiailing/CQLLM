/**
 * @name Direct imports per file
 * @description Measures the quantity of modules directly imported by each Python file.
 *              Elevated counts suggest strong module coupling, potentially undermining
 *              modularity and increasing complexity for maintenance and refactoring efforts.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// This query leverages the Python analysis framework to inspect AST structures and evaluate module interdependencies
import python

// For each Python source module, calculate the total number of its direct module dependencies
from ModuleValue sourceModule, int dependencyCount
where 
  // Calculate how many distinct modules are directly referenced by the source module
  dependencyCount = count(ModuleValue referencedModule | 
                        referencedModule = sourceModule.getAnImportedModule())
// Display the module's scope along with its associated direct import count
select sourceModule.getScope(), dependencyCount