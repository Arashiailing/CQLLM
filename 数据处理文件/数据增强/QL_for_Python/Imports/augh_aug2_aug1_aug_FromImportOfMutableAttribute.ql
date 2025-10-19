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

from ImportMember importedMember, ModuleValue originModule, AttrNode modificationNode, string attributeName
where
  // Match imported attribute name with modified attribute name
  importedMember.getName() = attributeName and
  // Verify origin module matches imported module's source
  originModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Confirm modification is a store operation within function scope
  modificationNode.isStore() and
  modificationNode.getScope() instanceof Function and
  // Ensure modification targets origin module's attribute
  modificationNode.getObject(attributeName).pointsTo(originModule) and
  // Verify imported attribute has module-level scope
  not importedMember.getScope() instanceof Function and
  // Ensure import and modification occur in different modules
  not importedMember.getEnclosingModule() = modificationNode.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not modificationNode.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", originModule,
  "module " + originModule.getName(), modificationNode, originModule.getName() + "." + modificationNode.getName()