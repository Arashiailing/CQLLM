/**
 * @name 'import *' may pollute namespace
 * @description Identifies star imports that cause namespace pollution when the 
 *              imported module doesn't define '__all__' to control its exports
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

// Query to detect namespace-polluting star imports
from ImportStar pollutingImport, ModuleValue importedModule
where 
  // Validate module existence and ensure name matches import statement
  importedModule.importedAs(pollutingImport.getImportedModuleName()) and
  not importedModule.isAbsent() and
  
  // Filter out built-in modules since they're inherently safe
  not importedModule.isBuiltin() and
  
  // Confirm the module lacks '__all__' definition in all relevant scopes
  not (
    // Check if '__all__' is defined in the module's main execution scope
    importedModule.getScope().(ImportTimeScope).definesName("__all__") or
    // Check if '__all__' is defined in the module's initialization scope (for packages)
    importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select pollutingImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()