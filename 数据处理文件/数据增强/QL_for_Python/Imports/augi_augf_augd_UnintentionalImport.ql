/**
 * @name Namespace pollution from wildcard imports
 * @description Identifies 'import *' statements that can pollute the namespace
 *              due to missing '__all__' definition in the imported module
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import the core Python analysis framework
import python

// Main query: Detect potentially harmful wildcard imports
from ImportStar wildcardImport, ModuleValue sourceModule
where 
  // Link the import statement with its corresponding module
  sourceModule.importedAs(wildcardImport.getImportedModuleName())
  and not sourceModule.isAbsent()
  and not sourceModule.isBuiltin()
  and not sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  and not sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")

select wildcardImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()