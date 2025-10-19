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

// Import the Python analysis library for parsing Python program structures
import python

// Iterate through all module objects and count their direct dependencies
from ModuleValue sourceModule, int dependencyCount
// Calculate the number of directly imported modules for each source module
where dependencyCount = count(ModuleValue importedModule | 
       importedModule = sourceModule.getAnImportedModule())
// Output the module's scope and its direct dependency count
select sourceModule.getScope(), dependencyCount