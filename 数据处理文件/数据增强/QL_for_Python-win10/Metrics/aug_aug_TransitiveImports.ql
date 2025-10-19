/**
 * @name Indirect imports per file
 * @description Computes the aggregate count of modules imported by each file, encompassing both
 *              direct imports (through import statements) and indirect imports (modules imported
 *              transitively via other imported modules).
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
// the import relation (transitive closure), excluding the source module itself
where 
  totalImportCount = count(ModuleValue transitiveImport | 
    transitiveImport = sourceModule.getAnImportedModule+() and 
    transitiveImport != sourceModule)
// Select the file scope of the source module and its calculated total import count
select sourceModule.getScope(), totalImportCount