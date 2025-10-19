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

// Import Python library for code parsing and analysis
import python

// For each module 'currentModule' in the codebase
from ModuleValue currentModule
// Select the scope of currentModule and the count of its direct imports
select currentModule.getScope(), count(ModuleValue directImport | directImport = currentModule.getAnImportedModule()) as importCount