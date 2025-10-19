/**
 * @name Importing value of mutable attribute
 * @description Detects when a mutable attribute is imported directly, causing local code to be unaware of changes to global state.
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

from ImportMember importedMember, ModuleValue sourceModule, AttrNode attributeStore, string attributeName
where
  // Verify the imported module matches the source module
  sourceModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure the imported member name matches the attribute name
  importedMember.getName() = attributeName and
  /* Attribute modification must occur within a function to ensure it happens during the imported value's lifetime */
  attributeStore.getScope() instanceof Function and
  /* The variable resulting from the import must have a longer lifetime (not function-scoped) */
  not importedMember.getScope() instanceof Function and
  // Confirm the operation is a store operation on the attribute
  attributeStore.isStore() and
  // Verify the attribute object refers to the imported module
  attributeStore.getObject(attributeName).pointsTo(sourceModule) and
  /* Import and modification must occur in different modules */
  not importedMember.getEnclosingModule() = attributeStore.getScope().getEnclosingModule() and
  /* Exclude modifications occurring within test code */
  not attributeStore.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attributeStore, sourceModule.getName() + "." + attributeStore.getName()