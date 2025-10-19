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

from ImportMember importedMember, ModuleValue modTarget, AttrNode assignNode, string attrNameStr
where
  // Validate module relationship between import and target
  modTarget.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Confirm imported attribute name matches assignment target
  importedMember.getName() = attrNameStr and
  // Ensure assignment occurs within function scope
  assignNode.getScope() instanceof Function and
  // Verify imported attribute has module-level scope
  not importedMember.getScope() instanceof Function and
  // Confirm operation is a store assignment
  assignNode.isStore() and
  // Validate assignment target references imported module
  assignNode.getObject(attrNameStr).pointsTo(modTarget) and
  // Ensure import and modification occur in separate modules
  not importedMember.getEnclosingModule() = assignNode.getScope().getEnclosingModule() and
  // Exclude test code modifications
  not assignNode.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing value of '" + attrNameStr +
    "' from $@ prevents observing changes made to $@ in local scope.", modTarget,
  "module " + modTarget.getName(), assignNode, modTarget.getName() + "." + assignNode.getName()