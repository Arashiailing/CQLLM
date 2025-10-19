/**
 * @name Direct imports per file
 * @description Measures the quantity of modules directly imported by each Python file.
 *              Elevated counts may signal excessive coupling, potentially undermining modularity and maintainability.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// Leverage Python analysis framework for AST traversal and module inspection
import python

// For each Python module, determine the count of its direct module dependencies
from ModuleValue sourceModule, int importQuantity
where 
  // Calculate the number of unique modules directly imported by the analyzed source module
  importQuantity = count(ModuleValue dependency | 
                       dependency = sourceModule.getAnImportedModule())
// Emit the source module's scope along with its corresponding direct import count
select sourceModule.getScope(), importQuantity