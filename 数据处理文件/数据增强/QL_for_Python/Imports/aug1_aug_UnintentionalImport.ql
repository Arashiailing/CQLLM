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

// Import Python analysis library for code examination
import python

// Identifies star import statements and their corresponding source modules
predicate findStarImport(ImportStar starImp, ModuleValue srcMod) {
  // Verify module name matches the imported name
  srcMod.importedAs(starImp.getImportedModuleName())
}

// Checks if a module properly defines '__all__' attribute
predicate moduleHasAllDefined(ModuleValue mod) {
  // Built-in modules are considered safe
  mod.isBuiltin()
  or
  // Check '__all__' definition in module scope
  mod.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check '__all__' definition in module initialization
  mod.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Main query to detect namespace-polluting imports
from ImportStar starImp, ModuleValue srcMod
where 
  findStarImport(starImp, srcMod) and
  not moduleHasAllDefined(srcMod) and
  not srcMod.isAbsent()
select starImp,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  srcMod, srcMod.getName()