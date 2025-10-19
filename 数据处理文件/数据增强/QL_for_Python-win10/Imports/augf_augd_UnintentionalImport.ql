/**
 * @name 'import *' may pollute namespace
 * @description Detects 'import *' statements that pollute the global namespace
 *              when the imported module lacks '__all__' definition
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Core Python analysis library import
import python

// Query logic: Find problematic 'import *' statements
from ImportStar starImportStmt, ModuleValue importedModule
where 
  // Establish relationship between import statement and imported module
  importedModule.importedAs(starImportStmt.getImportedModuleName())
  and not importedModule.isAbsent()
  and not (
    // Check if module properly defines '__all__' to control exports
    importedModule.isBuiltin()
    or
    // Module directly defines '__all__' in its import-time scope
    importedModule.getScope().(ImportTimeScope).definesName("__all__")
    or
    // Module's initialization package defines '__all__'
    importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select starImportStmt,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()