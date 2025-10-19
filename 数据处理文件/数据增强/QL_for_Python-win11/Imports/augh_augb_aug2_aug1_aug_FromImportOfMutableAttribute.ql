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
  // Verify attribute name consistency between import and modification
  importedAttr.getName() = attrName and
  
  // Establish module import relationship
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Identify mutable attribute modification operations
  attrModify.isStore() and
  attrModify.getObject(attrName).pointsTo(sourceModule) and
  
  // Enforce scope constraints: module-level import vs function-level modification
  not importedAttr.getScope() instanceof Function and
  attrModify.getScope() instanceof Function and
  
  // Ensure cross-module interaction
  not importedAttr.getEnclosingModule() = attrModify.getScope().getEnclosingModule() and
  
  // Exclude test code from analysis
  not attrModify.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrModify, sourceModule.getName() + "." + attrModify.getName()