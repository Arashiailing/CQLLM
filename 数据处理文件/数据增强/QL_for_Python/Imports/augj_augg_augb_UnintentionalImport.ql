/**
 * @name 'import *' may pollute namespace
 * @description Identifies star import statements that could cause namespace pollution
 *              when the imported module does not define '__all__' to limit exports
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

import python

// This query detects star imports that may introduce namespace pollution
from ImportStar starImportStatement, ModuleValue targetModule
where 
  // Establish relationship between the import statement and the module
  targetModule.importedAs(starImportStatement.getImportedModuleName())
  // Confirm that the imported module is accessible and not missing
  and not targetModule.isAbsent()
  // Check if the module controls its namespace with '__all__' or is built-in
  and not (
    // Built-in modules are exempt as they manage their exports internally
    targetModule.isBuiltin()
    or
    // Check if the module defines '__all__' in its import-time scope
    targetModule.getScope().(ImportTimeScope).definesName("__all__")
    or
    // Check if the module's initialization file defines '__all__'
    targetModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select starImportStatement,
  "This star import pollutes the namespace because module $@ lacks '__all__' definition.",
  targetModule, targetModule.getName()