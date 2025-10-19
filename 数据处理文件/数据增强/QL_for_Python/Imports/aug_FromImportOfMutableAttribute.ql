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

from ImportMember importedMember, ModuleValue moduleValue, AttrNode attributeStore, string attributeName
where
  // Verify module matching between imported and target module
  moduleValue.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure imported member name matches attribute name
  importedMember.getName() = attributeName and
  // Attribute modification must occur within function scope
  attributeStore.getScope() instanceof Function and
  // Imported variable must have extended lifetime (non-function scope)
  not importedMember.getScope() instanceof Function and
  // Confirm attribute is a store operation
  attributeStore.isStore() and
  // Verify attribute references the imported module
  attributeStore.getObject(attributeName).pointsTo(moduleValue) and
  // Ensure import and modification occur in different modules
  not importedMember.getEnclosingModule() = attributeStore.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not attributeStore.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", moduleValue,
  "module " + moduleValue.getName(), attributeStore, moduleValue.getName() + "." + attributeStore.getName()