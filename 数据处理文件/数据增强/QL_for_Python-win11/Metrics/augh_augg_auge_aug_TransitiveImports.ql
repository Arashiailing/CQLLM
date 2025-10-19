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

// For each root module and its corresponding transitive import count
from ModuleValue rootModule, int transitiveImportCount
// Calculate the transitive import count by counting all transitively imported modules
where transitiveImportCount = 
       count(ModuleValue importedModule | 
             importedModule = rootModule.getAnImportedModule+() and 
             importedModule != rootModule)
// Select the file scope of the root module and its computed transitive import count
select rootModule.getScope(), transitiveImportCount