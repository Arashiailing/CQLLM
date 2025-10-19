/**
 * @name Indirect imports per file
 * @description Calculates the total number of modules imported by each file, including both 
 *              direct imports (via import statements) and transitive imports (modules imported 
 *              by other imported modules).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the Python library for code analysis
import python

// For each module value and its corresponding import count
from ModuleValue moduleVal, int importCount
// Where the import count equals the number of distinct modules reachable through
// the import relation (transitive closure), excluding the module itself
where importCount = count(ModuleValue importedModule | 
       importedModule = moduleVal.getAnImportedModule+() and 
       importedModule != moduleVal)
// Select the file scope of the module and its calculated import count
select moduleVal.getScope(), importCount