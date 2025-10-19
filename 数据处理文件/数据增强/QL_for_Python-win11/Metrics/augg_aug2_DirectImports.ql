/**
 * @name Direct imports per file
 * @description Counts the number of modules that are directly imported by each file in the codebase.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import the Python library to enable code parsing and analysis capabilities
import python

// For each source module in the codebase
from ModuleValue sourceModule
// Select the source module's scope and count its directly imported modules
select sourceModule.getScope(), 
       count(ModuleValue directlyImportedModule | 
             directlyImportedModule = sourceModule.getAnImportedModule()) as importCount