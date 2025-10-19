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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode mutationPoint, string attributeName
where
  // Ensure imported attribute name matches mutated attribute name
  importedAttr.getName() = attributeName and
  // Verify module equivalence between imported and mutation target
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Confirm mutation point is a store operation
  mutationPoint.isStore() and
  // Verify mutation target references the imported module
  mutationPoint.getObject(attributeName).pointsTo(sourceModule) and
  // Ensure imported attribute has module-level scope (non-function)
  not importedAttr.getScope() instanceof Function and
  // Confirm mutation occurs within function scope
  mutationPoint.getScope() instanceof Function and
  // Verify import and mutation occur in different modules
  not importedAttr.getEnclosingModule() = mutationPoint.getScope().getEnclosingModule() and
  // Exclude mutations within test code
  not mutationPoint.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), mutationPoint, sourceModule.getName() + "." + mutationPoint.getName()