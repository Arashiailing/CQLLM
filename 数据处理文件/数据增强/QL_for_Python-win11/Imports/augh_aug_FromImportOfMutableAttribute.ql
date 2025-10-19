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

from ImportMember importedMember, ModuleValue importedModule, AttrNode attributeAssignment, string attributeName
where
  // Validate module consistency between import and target
  importedModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure imported member name matches the attribute being modified
  importedMember.getName() = attributeName and
  // Confirm attribute modification occurs within function scope
  attributeAssignment.getScope() instanceof Function and
  // Verify imported variable has module-level scope (non-function)
  not importedMember.getScope() instanceof Function and
  // Ensure operation is a store (assignment) operation
  attributeAssignment.isStore() and
  // Confirm attribute references the imported module
  attributeAssignment.getObject(attributeName).pointsTo(importedModule) and
  // Enforce cross-module modification (import and assignment in different modules)
  not importedMember.getEnclosingModule() = attributeAssignment.getScope().getEnclosingModule() and
  // Exclude test code modifications
  not attributeAssignment.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", importedModule,
  "module " + importedModule.getName(), attributeAssignment, importedModule.getName() + "." + attributeAssignment.getName()