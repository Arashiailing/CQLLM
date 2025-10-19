/**
 * @name Indirect imports per file
 * @description Calculates the total count of modules imported by each file, counting both direct imports
 *              through import statements and transitive imports (modules imported by other imported modules).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import Python library for parsing and analyzing Python code
import python

// Define variables for module analysis
from ModuleValue currentModule, int transitiveImportCount
// Calculate the number of transitive imports by recursively following import chains
where transitiveImportCount = count(ModuleValue importedModule | 
       importedModule = currentModule.getAnImportedModule+() and 
       importedModule != currentModule
     )
// Select the file scope and its computed transitive import count
select currentModule.getScope(), transitiveImportCount