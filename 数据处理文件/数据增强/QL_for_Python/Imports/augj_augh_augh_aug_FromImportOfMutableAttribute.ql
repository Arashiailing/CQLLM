/**
 * @name Importing value of mutable attribute
 * @description Detects direct imports of mutable attributes that prevent observing global state changes locally.
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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode mutationNode, string attributeName
where
  // Verify module import relationship
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure imported attribute name matches
  importedAttr.getName() = attributeName and
  // Confirm mutation occurs in function scope
  mutationNode.getScope() instanceof Function and
  // Verify imported attribute is module-level
  not importedAttr.getScope() instanceof Function and
  // Validate assignment operation
  mutationNode.isStore() and
  // Ensure mutation targets imported module
  mutationNode.getObject(attributeName).pointsTo(sourceModule) and
  // Enforce cross-module modification
  not importedAttr.getEnclosingModule() = mutationNode.getScope().getEnclosingModule() and
  // Exclude test-related code
  not mutationNode.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing value of '" + attributeName +
    "' from $@ prevents observing changes made to $@ in local scope.", sourceModule,
  "module " + sourceModule.getName(), mutationNode, sourceModule.getName() + "." + mutationNode.getName()