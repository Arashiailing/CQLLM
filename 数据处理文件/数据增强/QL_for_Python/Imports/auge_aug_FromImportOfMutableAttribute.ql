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

from ImportMember importedItem, ModuleValue sourceModule, AttrNode attrAssignment, string attrName
where
  // Verify module name consistency between import and source
  sourceModule.importedAs(importedItem.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure imported member name matches attribute name
  importedItem.getName() = attrName and
  // Attribute modification must occur within function scope
  exists(Function func | attrAssignment.getScope() = func) and
  // Imported variable must have module-level scope (non-function)
  not exists(Function func | importedItem.getScope() = func) and
  // Confirm attribute is a store operation
  attrAssignment.isStore() and
  // Verify attribute references the imported module
  attrAssignment.getObject(attrName).pointsTo(sourceModule) and
  // Ensure import and modification occur in different modules
  importedItem.getEnclosingModule() != attrAssignment.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not exists(TestScope test | attrAssignment.getScope().getScope*() = test)
select importedItem,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrAssignment, sourceModule.getName() + "." + attrAssignment.getName()