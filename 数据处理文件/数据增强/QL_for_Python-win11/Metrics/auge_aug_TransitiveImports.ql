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

// For each source module and its corresponding total import count
from ModuleValue sourceModule, int totalImportCount
// Where the total import count equals the number of distinct modules reachable through
// the transitive import relation, excluding the source module itself
where totalImportCount = count(ModuleValue reachableModule | 
       reachableModule = sourceModule.getAnImportedModule+() and 
       reachableModule != sourceModule)
// Select the file scope of the source module and its calculated total import count
select sourceModule.getScope(), totalImportCount