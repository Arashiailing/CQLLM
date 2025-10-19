/**
 * @name 'import *' may pollute namespace
 * @description Detects star imports that introduce namespace pollution when the 
 *              imported module lacks '__all__' definition to control exports
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

// Query to identify namespace-polluting star imports
from ImportStar problematicImport, ModuleValue sourceModule
where 
  // Verify module existence and name consistency
  sourceModule.importedAs(problematicImport.getImportedModuleName()) and
  not sourceModule.isAbsent() and
  
  // Exclude built-in modules as they are inherently safe
  not sourceModule.isBuiltin() and
  
  // Check for absence of '__all__' definition in relevant scopes
  not (
    // Check module's main execution scope
    sourceModule.getScope().(ImportTimeScope).definesName("__all__") or
    // Check module's initialization scope (for packages)
    sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select problematicImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()