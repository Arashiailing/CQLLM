/**
 * @name Importing value of mutable attribute
 * @description Detects direct imports of mutable attributes which prevent local observation of global state changes.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity high
 * @precision medium
 * @id py/import-of-mutable-attribute
 */

import python
import semmle.python.filters.Tests

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode modifiedNode, string attrName
where
  // Attribute name must match between import and modification
  importedAttr.getName() = attrName and
  // Verify source module matches imported module's origin
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Modification must be a store operation within function scope
  modifiedNode.isStore() and
  modifiedNode.getScope() instanceof Function and
  // Modification must target the source module's attribute
  modifiedNode.getObject(attrName).pointsTo(sourceModule) and
  // Imported attribute must have module-level scope (not function-local)
  not importedAttr.getScope() instanceof Function and
  // Import and modification must occur in different modules
  not importedAttr.getEnclosingModule() = modifiedNode.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not modifiedNode.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), modifiedNode, sourceModule.getName() + "." + modifiedNode.getName()