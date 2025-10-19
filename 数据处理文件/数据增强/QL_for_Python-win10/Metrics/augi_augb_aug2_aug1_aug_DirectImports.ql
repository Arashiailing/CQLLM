/**
 * @name Direct imports per file
 * @description Measures the quantity of modules that are directly imported by each Python file.
 *              Elevated counts might suggest strong coupling between modules, which could
 *              compromise modularity and make maintenance more challenging.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import the necessary Python analysis framework for AST traversal and module examination
import python

// For every Python source file, determine how many modules it directly imports
from ModuleValue sourceModule, int importCount
where 
  // Calculate the total number of distinct modules that the current file imports directly
  importCount = count(ModuleValue dependency | 
                    dependency = sourceModule.getAnImportedModule())
// Display the file's scope along with its corresponding direct import count
select sourceModule.getScope(), importCount