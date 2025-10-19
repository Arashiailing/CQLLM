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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attrAssignment, string attrName
where
  // Match imported module with actual module reference
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Verify attribute name consistency between import and assignment
  importedAttr.getName() = attrName and
  // Ensure assignment occurs within function scope
  attrAssignment.getScope() instanceof Function and
  // Imported attribute must have module-level scope (non-function)
  not importedAttr.getScope() instanceof Function and
  // Confirm assignment operation modifies the attribute
  attrAssignment.isStore() and
  // Verify assignment targets the imported module's attribute
  attrAssignment.getObject(attrName).pointsTo(sourceModule) and
  // Ensure import and modification occur in separate modules
  not importedAttr.getEnclosingModule() = attrAssignment.getScope().getEnclosingModule() and
  // Exclude modifications within test code scope
  not attrAssignment.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrAssignment, sourceModule.getName() + "." + attrAssignment.getName()