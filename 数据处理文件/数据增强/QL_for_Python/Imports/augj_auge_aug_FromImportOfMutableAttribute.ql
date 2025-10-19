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

from ImportMember importedMember, ModuleValue originalModule, AttrNode attributeModification, string attributeName
where
  // Verify module name consistency between import and source
  originalModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure imported member name matches attribute name
  importedMember.getName() = attributeName and
  // Confirm attribute is a store operation
  attributeModification.isStore() and
  // Attribute modification must occur within function scope
  exists(Function func | attributeModification.getScope() = func) and
  // Imported variable must have module-level scope (non-function)
  not exists(Function func | importedMember.getScope() = func) and
  // Verify attribute references the imported module
  attributeModification.getObject(attributeName).pointsTo(originalModule) and
  // Ensure import and modification occur in different modules
  importedMember.getEnclosingModule() != attributeModification.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not exists(TestScope test | attributeModification.getScope().getScope*() = test)
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", originalModule,
  "module " + originalModule.getName(), attributeModification, originalModule.getName() + "." + attributeName