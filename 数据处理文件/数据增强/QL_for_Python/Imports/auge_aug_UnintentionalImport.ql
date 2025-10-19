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

// Predicate to identify 'import *' statements and their source modules
predicate isStarImportFromModule(ImportStar imp, ModuleValue mod) {
  // Verify the module name matches the imported name
  mod.importedAs(imp.getImportedModuleName())
}

// Predicate to check if a module properly defines '__all__'
predicate moduleDefinesAll(ModuleValue mod) {
  // Built-in modules are considered safe
  mod.isBuiltin()
  or
  // Check if '__all__' is defined in the module's scope
  mod.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check if '__all__' is defined in the module's initialization
  mod.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Query to find problematic 'import *' statements
from ImportStar imp, ModuleValue mod
where 
  isStarImportFromModule(imp, mod) and
  not moduleDefinesAll(mod) and
  not mod.isAbsent()
select imp,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  mod, mod.getName()