/**
 * @name 'import *' may pollute namespace
 * @description Detects 'import *' statements that could pollute the namespace
 *              when the imported module lacks '__all__' definition. This practice
 *              can lead to unintended name conflicts and reduced code maintainability.
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import Python analysis library for code examination and AST traversal
import python

// Predicate to determine if a module properly defines '__all__' attribute
// This is crucial for controlling what gets exported via 'import *' statements
predicate moduleProperlyDefinesAll(ModuleValue sourceModule) {
  // Built-in modules are considered safe as they typically have controlled exports
  sourceModule.isBuiltin()
  or
  // Check if '__all__' is explicitly defined in the module's import-time scope
  sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check if '__all__' is defined in the module's initialization file
  sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Main query to identify problematic 'import *' statements
// These statements can pollute the namespace by importing all names from a module
// that doesn't explicitly specify which names should be exported
from ImportStar starImport, ModuleValue sourceModule
where 
  // Verify that the star import is from the specific module
  sourceModule.importedAs(starImport.getImportedModuleName()) and
  // Ensure the module doesn't properly define '__all__'
  not moduleProperlyDefinesAll(sourceModule) and
  // Exclude modules that are absent (not found)
  not sourceModule.isAbsent()
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()