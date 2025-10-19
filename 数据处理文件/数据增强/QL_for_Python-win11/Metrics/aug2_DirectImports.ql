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

// For each module 'moduleObj' in the codebase
from ModuleValue moduleObj
// Select the scope of moduleObj and the count of its direct imports
select moduleObj.getScope(), count(ModuleValue importedModule | importedModule = moduleObj.getAnImportedModule()) as importCount