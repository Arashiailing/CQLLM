/**
 * @name Star import namespace pollution
 * @description Detects 'import *' statements that could pollute the namespace
 *              when the imported module doesn't specify '__all__' to control exports
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import the Python analysis library for AST processing and module analysis
import python

/**
 * Determines if a module has a well-defined public interface.
 * A module is considered to have a controlled interface if:
 * 1. It's a built-in module (inherently controlled)
 * 2. It explicitly defines '__all__' in its import-time scope
 * 3. Its initialization module defines '__all__' in import-time scope
 */
predicate hasWellDefinedPublicInterface(ModuleValue importedModule) {
  // Built-in modules have controlled namespaces by design
  importedModule.isBuiltin()
  or
  // Check for '__all__' definition in the module's import-time scope
  importedModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check initialization module's import-time scope for '__all__' definition
  importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Query identifying star imports that risk namespace pollution
from ImportStar starImport, ModuleValue importedModule
where 
  // Establish relationship between import statement and imported module
  importedModule.importedAs(starImport.getImportedModuleName())
  and
  // Exclude modules with well-defined public interfaces
  not hasWellDefinedPublicInterface(importedModule)
  and
  // Filter out modules that cannot be located/resolved
  not importedModule.isAbsent()
select starImport,
  "Namespace pollution risk: Module $@ lacks '__all__' definition for star import.",
  importedModule, importedModule.getName()