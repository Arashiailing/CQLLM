/**
 * @name Indirect imports per file
 * @description Computes the aggregate count of modules imported by each file, encompassing both 
 *              direct imports (via import statements) and transitive dependencies (modules 
 *              imported by other imported modules).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the Python library for code analysis
import python

// For each origin module and its corresponding aggregate import count
from ModuleValue originModule, int aggregateImportCount
// Define the set of modules transitively imported by the origin module
where aggregateImportCount = count(ModuleValue importedModule | 
       // Check if the module is reachable through transitive imports
       importedModule = originModule.getAnImportedModule+() and 
       // Exclude the origin module from the count
       importedModule != originModule)
// Select the file scope of the origin module and its computed aggregate import count
select originModule.getScope(), aggregateImportCount