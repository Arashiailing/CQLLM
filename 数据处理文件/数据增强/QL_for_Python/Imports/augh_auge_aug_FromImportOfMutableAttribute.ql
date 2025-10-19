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

from ImportMember importedMember, ModuleValue originModule, AttrNode attrModification, string attributeName
where
  // Verify module name consistency between import and source
  originModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure imported member name matches attribute name
  importedMember.getName() = attributeName and
  // Attribute modification must occur within function scope
  exists(Function func | attrModification.getScope() = func) and
  // Imported variable must have module-level scope (non-function)
  not exists(Function func | importedMember.getScope() = func) and
  // Confirm attribute is a store operation
  attrModification.isStore() and
  // Verify attribute references the imported module
  attrModification.getObject(attributeName).pointsTo(originModule) and
  // Ensure import and modification occur in different modules
  importedMember.getEnclosingModule() != attrModification.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not exists(TestScope test | attrModification.getScope().getScope*() = test)
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", originModule,
  "module " + originModule.getName(), attrModification, originModule.getName() + "." + attrModification.getName()