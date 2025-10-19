/**
 * @name Direct imports per file
 * @description Calculates the number of modules directly imported by each file.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import Python library for code parsing and analysis
import python

// For each source module in the codebase
from ModuleValue sourceModule
// Select the module's scope and count its direct imports
select sourceModule.getScope(), 
       count(ModuleValue directlyImportedModule | 
             directlyImportedModule = sourceModule.getAnImportedModule()) as importCount