/**
 * @name Star import namespace pollution
 * @description Identifies 'import *' statements that risk namespace pollution
 *              when the source module doesn't define '__all__' to restrict exports
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import the Python analysis framework for AST and module analysis
import python

// Predicate to determine if a module provides a controlled public interface
predicate moduleHasControlledExports(ModuleValue importedModule) {
  // Built-in modules inherently have controlled namespaces
  importedModule.isBuiltin()
  or
  // Check if '__all__' is defined in the module's import-time scope
  importedModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Verify '__all__' exists in the module's initialization context
  importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Query to detect star imports that may cause namespace pollution
from ImportStar starImport, ModuleValue importedModule
where 
  // Establish relationship between import statement and source module
  importedModule.importedAs(starImport.getImportedModuleName())
  and
  // Filter out modules with properly controlled exports
  not moduleHasControlledExports(importedModule)
  and
  // Ensure the module can be located in the codebase
  not importedModule.isAbsent()
select starImport,
  "Namespace pollution risk: Module $@ lacks '__all__' definition for star import.",
  importedModule, importedModule.getName()