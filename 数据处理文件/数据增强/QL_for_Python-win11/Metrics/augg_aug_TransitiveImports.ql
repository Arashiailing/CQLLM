/**
 * @name Indirect imports per file
 * @description Computes the cumulative count of unique modules imported by each file,
 *              encompassing both explicit imports (via import statements) and all 
 *              transitively imported dependencies (modules imported by the imported modules).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// Import the Python library for code analysis
import python

// For each module entity and its calculated import footprint
from ModuleValue currentModule, int dependencyCount
// Where the dependency count represents the distinct modules reachable through
// the full import dependency chain (transitive closure), excluding self-references
where dependencyCount = count(ModuleValue dependency | 
       dependency = currentModule.getAnImportedModule+() and 
       dependency != currentModule)
// Select the module's file scope and its computed dependency count
select currentModule.getScope(), dependencyCount