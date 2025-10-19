/**
 * @name Importing value of mutable attribute
 * @description Detects when a mutable attribute is imported from a module, 
 *              which prevents local observation of changes made to that attribute
 *              in the source module.
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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode modifiedAttr, string attrName
where
  // Ensure the imported and modified attributes are the same and from the same source module
  importedAttr.getName() = attrName and
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Verify the attribute is being modified (stored) in the source module
  modifiedAttr.isStore() and
  modifiedAttr.getObject(attrName).pointsTo(sourceModule) and
  
  // Scope conditions: imported at module level, modified in function scope
  not importedAttr.getScope() instanceof Function and
  modifiedAttr.getScope() instanceof Function and
  
  // Ensure import and modification occur in different modules
  not importedAttr.getEnclosingModule() = modifiedAttr.getScope().getEnclosingModule() and
  
  // Exclude test code from analysis
  not modifiedAttr.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), modifiedAttr, sourceModule.getName() + "." + modifiedAttr.getName()