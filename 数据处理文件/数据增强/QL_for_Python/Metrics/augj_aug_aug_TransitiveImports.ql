/**
 * @name Indirect imports per file
 * @description Computes the aggregate count of modules imported by each file, encompassing both
 *              direct imports (through import statements) and indirect imports (modules imported
 *              transitively via other imported modules).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the Python library for code analysis
import python

// For each origin module and its corresponding cumulative import count
from ModuleValue rootModule, int aggregateImportCount
// Define the set of all modules transitively reachable from the root module
where 
  aggregateImportCount = count(ModuleValue reachableModule | 
    // Calculate all modules reachable through the import relation (transitive closure)
    reachableModule = rootModule.getAnImportedModule+() and 
    // Exclude the root module itself from the count
    reachableModule != rootModule)
// Select the file scope of the root module and its calculated aggregate import count
select rootModule.getScope(), aggregateImportCount