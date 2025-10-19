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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attributeMutation, string attributeName
where
  // Match imported attribute name with mutated attribute name
  importedAttr.getName() = attributeName and
  // Verify module relationship: sourceModule is the actual module being imported
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Confirm mutation is a store operation (assignment)
  attributeMutation.isStore() and
  // Ensure mutation targets the imported module's attribute
  attributeMutation.getObject(attributeName).pointsTo(sourceModule) and
  // Verify imported attribute has module-level scope (not function-local)
  not importedAttr.getScope() instanceof Function and
  // Ensure mutation occurs within function scope
  attributeMutation.getScope() instanceof Function and
  // Confirm import and mutation occur in different modules
  not importedAttr.getEnclosingModule() = attributeMutation.getScope().getEnclosingModule() and
  // Exclude mutations within test code
  not attributeMutation.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attributeMutation, sourceModule.getName() + "." + attributeMutation.getName()