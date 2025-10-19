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

// Predicate that checks if a module has a well-defined public interface
predicate hasWellDefinedPublicInterface(ModuleValue sourceModule) {
  // Built-in modules by definition have controlled namespaces
  sourceModule.isBuiltin()
  or
  // Look for '__all__' in the module's scope at import time
  sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check if '__all__' is defined in the module's initialization context
  sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Query that finds star imports that might pollute the namespace
from ImportStar wildcardImport, ModuleValue sourceModule
where 
  // Connect the import statement to the module being imported
  sourceModule.importedAs(wildcardImport.getImportedModuleName())
  and
  // Skip modules that properly define their public interface
  not hasWellDefinedPublicInterface(sourceModule)
  and
  // Exclude modules that cannot be located
  not sourceModule.isAbsent()
select wildcardImport,
  "Namespace pollution risk: Module $@ lacks '__all__' definition for star import.",
  sourceModule, sourceModule.getName()