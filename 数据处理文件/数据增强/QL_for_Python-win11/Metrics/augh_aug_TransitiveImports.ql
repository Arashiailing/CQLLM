/**
 * @name Indirect imports per file
 * @description Computes the aggregate count of modules imported by each file, encompassing 
 *              both immediate imports (through import statements) and indirect imports 
 *              (modules brought in by other imported modules).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the necessary Python analysis library
import python

// For every module value along with its associated import quantity
from ModuleValue mod, int totalImports
where 
  // Calculate the total number of distinct imported modules
  totalImports = count(ModuleValue importedMod | 
    // Include all modules reachable through the import relation (transitive closure)
    importedMod = mod.getAnImportedModule+() and 
    // Exclude the module itself from the count
    importedMod != mod
  )
// Output the file scope of the module and its computed import quantity
select mod.getScope(), totalImports