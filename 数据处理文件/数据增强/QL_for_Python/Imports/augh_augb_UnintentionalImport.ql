/**
 * @name 'import *' may pollute namespace
 * @description Importing a module using 'import *' may unintentionally pollute the global
 *              namespace if the module does not define `__all__`
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

import python

/**
 * Determines if a module explicitly defines the '__all__' attribute to control
 * which symbols are exported when using 'import *'. This attribute acts as a
 * whitelist for public API of the module.
 */
predicate moduleDefinesAllAttribute(ModuleValue importedModule) {
  // Built-in modules are considered to have defined '__all__' by default
  importedModule.isBuiltin()
  or
  // Check if the module's scope explicitly defines '__all__'
  importedModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check if the module's initialization file defines '__all__'
  importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

/**
 * Associates an 'import *' statement with its source module.
 * This predicate establishes the relationship between the import AST node
 * and the actual module being imported.
 */
predicate linksStarImportToModule(ImportStar starImportNode, ModuleValue importedModule) {
  // Verify that the source module name matches the imported module name
  importedModule.importedAs(starImportNode.getImportedModuleName())
}

// Main query to detect namespace pollution from 'import *' statements
from ImportStar starImportNode, ModuleValue importedModule
where 
  // Establish relationship between import statement and source module
  linksStarImportToModule(starImportNode, importedModule)
  // Exclude modules that properly define '__all__' to control exports
  and not moduleDefinesAllAttribute(importedModule)
  // Ensure the imported module actually exists in the codebase
  and not importedModule.isAbsent()
select starImportNode,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()