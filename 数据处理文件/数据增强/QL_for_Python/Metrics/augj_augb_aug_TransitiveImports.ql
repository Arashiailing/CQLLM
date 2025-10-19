/**
 * @name Indirect imports per file
 * @description Calculates the total number of modules transitively imported by each file.
 *              This includes both direct imports (explicit import statements) and 
 *              indirect imports (modules brought in through the dependency chain).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the Python library for code analysis
import python

// For each origin module and its corresponding import chain count
from ModuleValue originModule, int importChainCount
// Where the import chain count is computed as the total number of distinct modules
// that can be reached via the transitive closure of the import relation,
// excluding the origin module itself from the count
where 
  // Define the set of modules transitively imported by the origin module
  exists(int dependencyCount |
    dependencyCount = count(ModuleValue dependentModule | 
      dependentModule = originModule.getAnImportedModule+() and 
      dependentModule != originModule) and
    // Assign the computed count to our result variable
    importChainCount = dependencyCount
  )
// Select the file scope associated with the origin module and its computed import chain count
select originModule.getScope(), importChainCount