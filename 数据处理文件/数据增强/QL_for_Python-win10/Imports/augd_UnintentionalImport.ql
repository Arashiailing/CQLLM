/**
 * @name 'import *' may pollute namespace
 * @description Detects 'import *' statements that pollute the global namespace
 *              when the imported module lacks '__all__' definition
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Core Python analysis library import
import python

/**
 * Predicate identifying 'import *' statements and their source modules.
 * Establishes relationship between import statement and imported module.
 */
predicate starImportRelation(ImportStar imp, ModuleValue sourceMod) {
  sourceMod.importedAs(imp.getImportedModuleName())
}

/**
 * Predicate checking if module properly defines '__all__' to control exports.
 * Returns true for modules that explicitly limit exported symbols.
 */
predicate hasExplicitExportDefinition(ModuleValue sourceMod) {
  // Built-in modules are considered safe by convention
  sourceMod.isBuiltin()
  or
  // Module directly defines '__all__' in its import-time scope
  sourceMod.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Module's initialization package defines '__all__'
  sourceMod.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Query logic: Find problematic 'import *' statements
from ImportStar imp, ModuleValue sourceMod
where 
  starImportRelation(imp, sourceMod) 
  and not hasExplicitExportDefinition(sourceMod) 
  and not sourceMod.isAbsent()
select imp,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceMod, sourceMod.getName()