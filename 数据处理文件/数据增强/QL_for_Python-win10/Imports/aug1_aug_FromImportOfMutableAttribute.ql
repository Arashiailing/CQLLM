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

from ImportMember importedMember, ModuleValue targetModule, AttrNode attrAssignment, string attrName
where
  // Match imported member name with attribute name
  importedMember.getName() = attrName and
  // Verify module matching between imported and target module
  targetModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Confirm attribute is a store operation
  attrAssignment.isStore() and
  // Ensure attribute references the imported module
  attrAssignment.getObject(attrName).pointsTo(targetModule) and
  // Verify imported variable has module-level scope (non-function)
  not importedMember.getScope() instanceof Function and
  // Ensure attribute modification occurs within function scope
  attrAssignment.getScope() instanceof Function and
  // Confirm import and modification occur in different modules
  not importedMember.getEnclosingModule() = attrAssignment.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not attrAssignment.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", targetModule,
  "module " + targetModule.getName(), attrAssignment, targetModule.getName() + "." + attrAssignment.getName()