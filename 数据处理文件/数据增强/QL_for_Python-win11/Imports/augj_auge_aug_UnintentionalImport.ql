/**
 * @name 'import *' may pollute namespace
 * @description Identifies 'import *' statements that potentially pollute the namespace
 *              when the imported module doesn't define '__all__'
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Python analysis library import for code inspection
import python

// Predicate that establishes the relationship between star imports and their source modules
predicate isStarImportFromModule(ImportStar starImport, ModuleValue sourceModule) {
  // Ensure the module name corresponds to the imported module name
  sourceModule.importedAs(starImport.getImportedModuleName())
}

// Predicate that determines if a module correctly specifies '__all__'
predicate moduleDefinesAll(ModuleValue sourceModule) {
  // Built-in modules are exempt from this check
  sourceModule.isBuiltin()
  or
  // Verify '__all__' is defined within the module's scope
  sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Verify '__all__' is defined within the module's initialization
  sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Main query to detect problematic star imports
from ImportStar starImport, ModuleValue sourceModule
where 
  // Check if this is a star import from a specific module
  isStarImportFromModule(starImport, sourceModule) and
  // Ensure the module doesn't define '__all__'
  not moduleDefinesAll(sourceModule) and
  // Ensure the module is present (not absent)
  not sourceModule.isAbsent()
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()