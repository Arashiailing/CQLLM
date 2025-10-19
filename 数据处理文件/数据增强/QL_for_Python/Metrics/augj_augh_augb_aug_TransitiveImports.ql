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

// Define the calculation for transitive imports count
// This counts all distinct modules reachable through the import chain
// excluding the source module itself to avoid self-reference
from ModuleValue sourceModule, int transitiveImportCount
where 
  // Calculate the count by finding all modules transitively imported
  transitiveImportCount = count(ModuleValue dependencyModule | 
    // Use transitive closure (+) to get all modules in the import chain
    dependencyModule = sourceModule.getAnImportedModule+() and 
    // Exclude the source module from the count
    dependencyModule != sourceModule)
// Select the file scope of the source module and its computed transitive import count
select sourceModule.getScope(), transitiveImportCount