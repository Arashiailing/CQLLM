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
from ImportStar starImport, ModuleValue sourceModule
where 
  // Verify module name matches the imported name
  sourceModule.importedAs(starImport.getImportedModuleName()) and
  // Ensure module is not absent (exists in codebase)
  not sourceModule.isAbsent() and
  // Check module lacks '__all__' definition in all possible locations
  not (
    // Built-in modules are considered safe
    sourceModule.isBuiltin() or
    // Check '__all__' in module's main scope
    sourceModule.getScope().(ImportTimeScope).definesName("__all__") or
    // Check '__all__' in module's initialization scope
    sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()