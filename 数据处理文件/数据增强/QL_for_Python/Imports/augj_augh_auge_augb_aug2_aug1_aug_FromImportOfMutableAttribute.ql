/**
 * @name Importing value of mutable attribute
 * @description Detects direct imports of mutable attribute values which prevents observing 
 *              global state changes locally. This pattern can lead to unexpected behavior 
 *              when the attribute is modified in its original module.
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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attrMod, string attrName
where
  // Ensure attribute name consistency between import and modification
  importedAttr.getName() = attrName and
  
  // Validate module import relationship
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Confirm attribute modification operation
  attrMod.isStore() and
  attrMod.getObject(attrName).pointsTo(sourceModule) and
  
  // Enforce scope constraints: module-level import vs function-level modification
  not importedAttr.getScope() instanceof Function and
  attrMod.getScope() instanceof Function and
  
  // Ensure cross-module constraint: import and modification in different modules
  not importedAttr.getEnclosingModule() = attrMod.getScope().getEnclosingModule() and
  
  // Exclude test code from analysis
  not attrMod.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrMod, sourceModule.getName() + "." + attrMod.getName()