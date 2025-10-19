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

/**
 * Helper predicate to check if a module defines its public API properly
 * Returns true if the module either:
 * - Is a built-in module (which inherently controls namespace)
 * - Defines '__all__' in its import-time scope
 * - Has '__all__' defined in its initialization context
 */
predicate definesPublicAPIControl(ModuleValue sourceModule) {
  // Built-in modules inherently control their namespace
  sourceModule.isBuiltin()
  or
  // Check for '__all__' definition in the module's import-time scope
  exists(ImportTimeScope scope | scope = sourceModule.getScope() | scope.definesName("__all__"))
  or
  // Verify '__all__' exists in the module's initialization context
  exists(ImportTimeScope initScope | 
    initScope = sourceModule.getScope().getInitModule().(ImportTimeScope) | 
    initScope.definesName("__all__")
  )
}

// Main query to identify problematic star imports that may pollute namespace
from ImportStar starImport, ModuleValue sourceModule
where 
  // Link the import statement to the module it imports
  sourceModule.importedAs(starImport.getImportedModuleName())
  and
  // Only consider modules that do not properly define their public API
  not definesPublicAPIControl(sourceModule)
  and
  // Exclude modules that cannot be resolved (missing modules)
  not sourceModule.isAbsent()
select starImport,
  "Namespace pollution risk: Module $@ lacks '__all__' definition for star import.",
  sourceModule, sourceModule.getName()