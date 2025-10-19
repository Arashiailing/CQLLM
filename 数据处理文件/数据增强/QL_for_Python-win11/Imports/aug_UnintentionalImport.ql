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
predicate matchesStarImport(ImportStar starImport, ModuleValue sourceModule) {
  // Verify the module name matches the imported name
  sourceModule.importedAs(starImport.getImportedModuleName())
}

// Predicate to check if a module properly defines '__all__'
predicate hasAllDefined(ModuleValue sourceModule) {
  // Built-in modules are considered safe
  sourceModule.isBuiltin()
  or
  // Check if '__all__' is defined in the module's scope
  sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check if '__all__' is defined in the module's initialization
  sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Query to find problematic 'import *' statements
from ImportStar starImport, ModuleValue sourceModule
where 
  matchesStarImport(starImport, sourceModule) and
  not hasAllDefined(sourceModule) and
  not sourceModule.isAbsent()
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()