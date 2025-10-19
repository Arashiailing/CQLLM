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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attrModify, string attrName
where
  // Ensure imported attribute name matches the modified attribute name
  importedAttr.getName() = attrName and
  // Verify source module matches the imported module's origin
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Confirm attribute modification is a store operation
  attrModify.isStore() and
  // Ensure modification targets the source module's attribute
  attrModify.getObject(attrName).pointsTo(sourceModule) and
  // Verify imported attribute has module-level scope (not function-local)
  not importedAttr.getScope() instanceof Function and
  // Ensure modification occurs within function scope
  attrModify.getScope() instanceof Function and
  // Confirm import and modification occur in different modules
  not importedAttr.getEnclosingModule() = attrModify.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not attrModify.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrModify, sourceModule.getName() + "." + attrModify.getName()