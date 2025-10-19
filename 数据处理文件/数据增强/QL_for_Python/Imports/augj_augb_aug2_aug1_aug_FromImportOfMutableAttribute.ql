/**
 * @name Importing value of mutable attribute
 * @description Detects when a mutable attribute is imported by value, which prevents
 *              observing global state changes locally. This can lead to inconsistencies
 *              when the attribute is modified in the source module.
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
  // Attribute name consistency check
  importedAttr.getName() = attrName and
  
  // Module import relationship verification
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Attribute modification operation validation
  attrModification.isStore() and
  attrModification.getObject(attrName).pointsTo(sourceModule) and
  
  // Scope constraints for import and modification
  not importedAttr.getScope() instanceof Function and  // Module-level import
  attrModification.getScope() instanceof Function and      // Function-level modification
  not importedAttr.getEnclosingModule() = attrModification.getScope().getEnclosingModule() and  // Cross-module
  
  // Test code exclusion
  not attrModification.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrModification, sourceModule.getName() + "." + attrModification.getName()