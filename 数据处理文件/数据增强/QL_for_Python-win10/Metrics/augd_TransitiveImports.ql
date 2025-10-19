/**
 * @name Indirect imports per file
 * @description The number of modules imported by this file - either directly by an import statement,
 *              or indirectly (by being imported by an imported module).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg
 * @tags modularity
 */

import python

// Define the transitive import count for each module
from ModuleValue moduleEntity, int transitiveImportCount
where 
  // Calculate the total number of modules transitively imported by moduleEntity
  transitiveImportCount = count(ModuleValue importedModule | 
    // Find all modules reachable through the import relation (transitive closure)
    importedModule = moduleEntity.getAnImportedModule+() and 
    // Exclude the module itself from the count
    importedModule != moduleEntity
  )
select moduleEntity.getScope(), transitiveImportCount