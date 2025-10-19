/**
 * @name Direct imports per file
 * @description Analyzes and counts the number of modules directly imported by each source file.
 *              This helps in understanding the module dependencies and complexity of each file.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import the Python library for code parsing and analysis capabilities
import python

// For each source module in the codebase
from ModuleValue originModule
// Select the module's scope and count its direct imports
select originModule.getScope(), 
       count(ModuleValue importedModule | 
             importedModule = originModule.getAnImportedModule()) as importCount