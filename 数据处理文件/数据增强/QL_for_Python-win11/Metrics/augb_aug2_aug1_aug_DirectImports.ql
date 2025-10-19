/**
 * @name Direct imports per file
 * @description This metric quantifies the number of modules directly imported by each Python file.
 *              A high count may indicate excessive coupling, potentially affecting modularity and maintainability.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Import the Python analysis framework for AST traversal and module analysis
import python

// For each Python file, calculate the count of its direct module imports
from ModuleValue fileModule, int directImportCount
where 
  // Compute the number of unique modules directly imported by the file being analyzed
  directImportCount = count(ModuleValue importedModule | 
                          importedModule = fileModule.getAnImportedModule())
// Output the file scope along with its corresponding direct import count
select fileModule.getScope(), directImportCount