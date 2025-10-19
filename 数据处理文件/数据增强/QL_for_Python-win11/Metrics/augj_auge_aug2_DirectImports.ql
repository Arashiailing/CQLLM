/**
 * @name Direct imports per file
 * @description Analyzes and quantifies the number of modules that each file directly imports.
 *              This metric helps identify files with high coupling, which may indicate
 *              potential maintenance challenges or architectural issues.
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

// For each module in the codebase, calculate its direct import dependencies
from ModuleValue moduleToAnalyze
// Retrieve the scope of the module being analyzed
// and compute the count of modules it directly imports
select moduleToAnalyze.getScope(),
       count(ModuleValue importedDependency |
             // Identify modules that are directly imported by the current module
             importedDependency = moduleToAnalyze.getAnImportedModule()
       ) as directImportCount