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

// Checks if a module properly defines '__all__' attribute
predicate moduleDefinesAllAttribute(ModuleValue moduleVal) {
  // Built-in modules are considered safe
  moduleVal.isBuiltin()
  or
  // Check '__all__' definition in module scope
  moduleVal.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check '__all__' definition in module initialization
  moduleVal.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Identifies star import statements and their corresponding source modules
predicate locateStarImport(ImportStar starImportStmt, ModuleValue sourceModule) {
  // Verify module name matches the imported name
  sourceModule.importedAs(starImportStmt.getImportedModuleName())
}

// Main query to detect namespace-polluting imports
from ImportStar starImportStmt, ModuleValue sourceModule
where 
  locateStarImport(starImportStmt, sourceModule) and
  not moduleDefinesAllAttribute(sourceModule) and
  not sourceModule.isAbsent()
select starImportStmt,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()