/**
 * @name Indirect imports per file
 * @description Computes the aggregate count of modules transitively imported by each file.
 *              This encompasses both direct imports (explicit import statements) and 
 *              indirect imports (modules imported by other modules in the dependency chain).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the Python library for code analysis
import python

// For each source module and its corresponding transitive import count
from ModuleValue sourceModule, int transitiveImportCount
// Where the transitive import count is calculated as the number of distinct modules
// reachable through the import relation's transitive closure, excluding the source module itself
where transitiveImportCount = count(ModuleValue reachableModule | 
       reachableModule = sourceModule.getAnImportedModule+() and 
       reachableModule != sourceModule)
// Select the file scope of the source module and its computed transitive import count
select sourceModule.getScope(), transitiveImportCount