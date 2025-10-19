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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attrModification, string attrName
where
  // Attribute name consistency between import and modification
  importedAttr.getName() = attrName and
  
  // Module import relationship verification
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Attribute modification operation validation
  attrModification.isStore() and
  attrModification.getObject(attrName).pointsTo(sourceModule) and
  
  // Scope constraints: module-level import vs function-level modification
  not importedAttr.getScope() instanceof Function and
  attrModification.getScope() instanceof Function and
  
  // Cross-module constraint: import and modification in different modules
  not importedAttr.getEnclosingModule() = attrModification.getScope().getEnclosingModule() and
  
  // Test code exclusion
  not attrModification.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrModification, sourceModule.getName() + "." + attrModification.getName()