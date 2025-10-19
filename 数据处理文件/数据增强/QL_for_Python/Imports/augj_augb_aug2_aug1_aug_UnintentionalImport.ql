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
from ImportStar namespacePollutingImport, ModuleValue targetModule
where 
  // Verify module existence and name consistency
  targetModule.importedAs(namespacePollutingImport.getImportedModuleName()) and
  not targetModule.isAbsent() and
  
  // Exclude built-in modules as they are considered safe
  not targetModule.isBuiltin() and
  
  // Check absence of '__all__' definition in all relevant scopes
  not (
    // Check the module's main execution scope
    targetModule.getScope().(ImportTimeScope).definesName("__all__") or
    // Check the module's initialization scope (for packages)
    targetModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select namespacePollutingImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  targetModule, targetModule.getName()