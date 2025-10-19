/**
 * @name Indirect imports per file
 * @description Computes the cumulative count of modules imported by each file, encompassing both
 *              direct imports and those imported transitively through other modules.
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg
 * @tags modularity
 */

import python

// For each module, determine its total transitive import count
from ModuleValue currentModule, int totalImports
where 
  // Aggregate all modules reachable through the import chain
  totalImports = count(ModuleValue imported | 
    // Traverse the import graph transitively to find all dependencies
    imported = currentModule.getAnImportedModule+() and 
    // Exclude self-reference to avoid counting the module as its own import
    imported != currentModule
  )
select currentModule.getScope(), totalImports