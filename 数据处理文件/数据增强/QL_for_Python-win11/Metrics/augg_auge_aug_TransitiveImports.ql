/**
 * @name Indirect imports per file
 * @description Computes the cumulative count of modules imported by each file, encompassing
 *              both immediate imports (via import statements) and indirect imports (modules
 *              imported by dependencies of the file).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the Python library for code analysis
import python

// For each initial module and its corresponding aggregate import count
from ModuleValue initialModule, int aggregateImportCount
// Calculate the aggregate import count by counting all transitively imported modules
where aggregateImportCount = 
       count(ModuleValue accessibleModule | 
             accessibleModule = initialModule.getAnImportedModule+() and 
             accessibleModule != initialModule)
// Select the file scope of the initial module and its computed aggregate import count
select initialModule.getScope(), aggregateImportCount