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

from ImportMember importedAttribute, ModuleValue importedModule, AttrNode attributeModification, string attributeName
where
  // Verify attribute name consistency between import and modification
  importedAttribute.getName() = attributeName and
  
  // Validate module import relationship
  importedModule.importedAs(importedAttribute.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Confirm attribute modification operation
  attributeModification.isStore() and
  attributeModification.getObject(attributeName).pointsTo(importedModule) and
  
  // Enforce scope constraints: module-level import vs function-level modification
  not importedAttribute.getScope() instanceof Function and
  attributeModification.getScope() instanceof Function and
  
  // Ensure cross-module constraint: import and modification in different modules
  not importedAttribute.getEnclosingModule() = attributeModification.getScope().getEnclosingModule() and
  
  // Exclude test code from analysis
  not attributeModification.getScope().getScope*() instanceof TestScope
select importedAttribute,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will not be observed locally.", importedModule,
  "module " + importedModule.getName(), attributeModification, importedModule.getName() + "." + attributeModification.getName()