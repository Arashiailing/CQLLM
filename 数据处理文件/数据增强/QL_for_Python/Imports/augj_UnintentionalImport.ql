/**
 * @name 'import *' may pollute namespace
 * @description Detects namespace pollution caused by 'import *' statements
 *              when the imported module lacks an explicit '__all__' definition
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

import python

from ImportStar starImport, ModuleValue sourceModule
where 
  // Verify the imported module matches the source module reference
  sourceModule.importedAs(starImport.getImportedModuleName()) and
  // Ensure source module exists and isn't missing
  not sourceModule.isAbsent() and
  // Check if source module defines '__all__' to control exports
  not (
    // Built-in modules are considered safe
    sourceModule.isBuiltin() or
    // Direct '__all__' definition in module scope
    sourceModule.getScope().(ImportTimeScope).definesName("__all__") or
    // '__all__' definition in module's initialization scope
    sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()