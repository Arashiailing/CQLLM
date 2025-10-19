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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attrWrite, string attrName
where
  // Validate module consistency between import and target
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure imported member name matches the attribute name
  importedAttr.getName() = attrName and
  // Attribute modification must occur within function scope
  attrWrite.getScope() instanceof Function and
  // Imported variable must have module-level scope (non-function)
  not importedAttr.getScope() instanceof Function and
  // Confirm attribute operation is a store (write) operation
  attrWrite.isStore() and
  // Verify attribute references the imported module
  attrWrite.getObject(attrName).pointsTo(sourceModule) and
  // Ensure import and modification occur in different modules
  not importedAttr.getEnclosingModule() = attrWrite.getScope().getEnclosingModule() and
  // Exclude modifications within test code scope
  not attrWrite.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrWrite, sourceModule.getName() + "." + attrWrite.getName()