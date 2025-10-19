/**
 * @name Importing value of mutable attribute
 * @description Direct import of mutable attribute values prevents observing global state changes locally.
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

from ImportMember importedMember, ModuleValue originModule, AttrNode modifiedAttrNode, string attributeName
where
  // Attribute name consistency between import and modification
  importedMember.getName() = attributeName and
  // Verify module origin relationship
  originModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Modification must be a store operation (assignment)
  modifiedAttrNode.isStore() and
  // Target object must be the origin module
  modifiedAttrNode.getObject(attributeName).pointsTo(originModule) and
  // Imported attribute must have module-level scope
  not importedMember.getScope() instanceof Function and
  // Modification must occur within function scope
  modifiedAttrNode.getScope() instanceof Function and
  // Import and modification must be in different modules
  not importedMember.getEnclosingModule() = modifiedAttrNode.getScope().getEnclosingModule() and
  // Exclude test code modifications
  not modifiedAttrNode.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", originModule,
  "module " + originModule.getName(), modifiedAttrNode, originModule.getName() + "." + modifiedAttrNode.getName()