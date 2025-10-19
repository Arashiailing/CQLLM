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

from ImportMember importedAttribute, ModuleValue sourceMod, AttrNode modifiedAttribute, string attributeName
where
  // Attribute name consistency: imported and modified attributes share the same name
  importedAttribute.getName() = attributeName and
  
  // Module relationship: source module is properly imported via import expression
  sourceMod.importedAs(importedAttribute.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Modification operation: attribute is being stored/modified in source module context
  modifiedAttribute.isStore() and
  modifiedAttribute.getObject(attributeName).pointsTo(sourceMod) and
  
  // Scope constraints: import occurs at module level, modification within function scope
  not importedAttribute.getScope() instanceof Function and
  modifiedAttribute.getScope() instanceof Function and
  
  // Module isolation: import and modification occur in different modules
  not importedAttribute.getEnclosingModule() = modifiedAttribute.getScope().getEnclosingModule() and
  
  // Test exclusion: modification doesn't occur in test code
  not modifiedAttribute.getScope().getScope*() instanceof TestScope
select importedAttribute,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceMod,
  "module " + sourceMod.getName(), modifiedAttribute, sourceMod.getName() + "." + modifiedAttribute.getName()