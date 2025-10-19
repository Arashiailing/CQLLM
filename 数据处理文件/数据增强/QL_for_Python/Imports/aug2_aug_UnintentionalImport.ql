/**
 * @name 'import *' may pollute namespace
 * @description Identifies 'import *' statements that risk namespace pollution
 *              when the imported module lacks '__all__' definition
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import Python analysis library for AST traversal and module inspection
import python

// Predicate to determine if a module properly exports its public API
predicate properlyDefinesPublicAPI(ModuleValue importedModule) {
  // Built-in modules inherently control their namespace
  importedModule.isBuiltin()
  or
  // Check for '__all__' definition in the module's import-time scope
  importedModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Verify '__all__' exists in the module's initialization context
  importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Query to detect namespace-polluting star imports
from ImportStar starImportStmt, ModuleValue importedModule
where 
  // Establish relationship between import statement and source module
  importedModule.importedAs(starImportStmt.getImportedModuleName())
  and
  // Exclude modules with proper public API definitions
  not properlyDefinesPublicAPI(importedModule)
  and
  // Filter out modules that can't be resolved
  not importedModule.isAbsent()
select starImportStmt,
  "Namespace pollution risk: Module $@ lacks '__all__' definition for star import.",
  importedModule, importedModule.getName()