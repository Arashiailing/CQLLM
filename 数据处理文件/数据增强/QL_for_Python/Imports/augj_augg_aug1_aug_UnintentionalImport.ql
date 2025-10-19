/**
 * @name 'import *' may pollute namespace
 * @description Identifies 'import *' statements that can cause namespace pollution
 *              when the imported module doesn't define '__all__' attribute
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

// Checks if a module properly defines '__all__' attribute
predicate moduleDefinesAllAttribute(ModuleValue modVal) {
  // Built-in modules are considered safe
  modVal.isBuiltin()
  or
  // Check '__all__' definition in module scope
  modVal.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check '__all__' definition in module initialization
  modVal.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Identifies star import statements and their corresponding source modules
predicate locateStarImport(ImportStar starImp, ModuleValue srcMod) {
  // Verify module name matches the imported name
  srcMod.importedAs(starImp.getImportedModuleName())
}

// Main query to detect namespace-polluting imports
from ImportStar starImp, ModuleValue srcMod
where 
  locateStarImport(starImp, srcMod) and
  not moduleDefinesAllAttribute(srcMod) and
  not srcMod.isAbsent()
select starImp,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  srcMod, srcMod.getName()