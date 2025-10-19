/**
 * @name 'import *' may pollute namespace
 * @description Detects 'import *' statements that could pollute the namespace
 *              when the imported module lacks '__all__' definition
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

import python

// Query identifies star imports that risk namespace pollution
from ImportStar wildcardImport, ModuleValue importedModule
where 
  // Verify module correspondence between import and source
  importedModule.importedAs(wildcardImport.getImportedModuleName())
  // Exclude modules with '__all__' namespace control
  and not (
    // Built-in modules are considered safe
    importedModule.isBuiltin()
    or
    // Check for '__all__' in module's import-time scope
    importedModule.getScope().(ImportTimeScope).definesName("__all__")
    or
    // Check for '__all__' in module's initialization file
    importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
  // Ensure the imported module actually exists
  and not importedModule.isAbsent()
select wildcardImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()