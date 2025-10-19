/**
 * @name 'import *' may pollute namespace
 * @description Detects star imports that can potentially pollute the namespace
 *              when the imported module does not define '__all__' attribute
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import Python analysis framework for code examination
import python

// Identify star imports that pollute the namespace
from ImportStar namespacePolluter, ModuleValue importedModule
where 
  // Verify the imported module name matches the actual module
  importedModule.importedAs(namespacePolluter.getImportedModuleName()) and
  // Ensure the module exists in the codebase
  not importedModule.isAbsent() and
  // Check if the module is not a built-in module
  not importedModule.isBuiltin() and
  // Check if '__all__' is not defined in the module's main scope
  not importedModule.getScope().(ImportTimeScope).definesName("__all__") and
  // Check if '__all__' is not defined in the module's initialization scope
  not importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
select namespacePolluter,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()