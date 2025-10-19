/**
 * @name 'import *' may pollute namespace
 * @description Identifies star imports that pollute the namespace when the 
 *              imported module lacks '__all__' definition
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import Python analysis library for code examination
import python

// Main query to detect namespace-polluting imports
from ImportStar pollutingImport, ModuleValue importedModule
where 
  // Verify module existence and name consistency
  importedModule.importedAs(pollutingImport.getImportedModuleName()) and
  not importedModule.isAbsent() and
  
  // Exclude safe modules (built-ins are always safe)
  not importedModule.isBuiltin() and
  
  // Check absence of '__all__' definition in all relevant scopes
  not (
    // Check module's main execution scope
    importedModule.getScope().(ImportTimeScope).definesName("__all__") or
    // Check module's initialization scope (for packages)
    importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select pollutingImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()