/**
 * @name 'import *' may pollute namespace
 * @description Using 'import *' statement can lead to namespace pollution when the imported module
 *              doesn't define `__all__` variable to specify which names should be exported.
 *              This practice makes it harder to determine the origin of names in the importing module
 *              and may cause unexpected name conflicts.
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import the Python analysis library
import python

// Identify all wildcard imports that don't have proper namespace control
from ImportStar starImport, ModuleValue importedModule
where 
  // Verify that the module name in the import matches the actual module
  importedModule.importedAs(starImport.getImportedModuleName())
  // Ensure the module actually exists in the codebase
  and not importedModule.isAbsent()
  // Exclude built-in modules as they typically have controlled namespaces
  and not importedModule.isBuiltin()
  // Exclude modules that define '__all__' in their main scope
  and not importedModule.getScope().(ImportTimeScope).definesName("__all__")
  // Exclude modules that define '__all__' in their __init__.py file
  and not importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()