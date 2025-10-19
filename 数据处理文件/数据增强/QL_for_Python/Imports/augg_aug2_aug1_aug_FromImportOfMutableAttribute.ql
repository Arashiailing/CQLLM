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

from ImportMember importedMember, ModuleValue originalModule, AttrNode attributeModification, string attributeName
where
  // Match imported attribute name with modified attribute name
  importedMember.getName() = attributeName and
  // Verify original module matches imported module's origin
  originalModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Confirm attribute modification is a store operation
  attributeModification.isStore() and
  // Ensure modification targets original module's attribute
  attributeModification.getObject(attributeName).pointsTo(originalModule) and
  
  // Verify imported attribute has module-level scope
  not importedMember.getScope() instanceof Function and
  // Ensure modification occurs within function scope
  attributeModification.getScope() instanceof Function and
  
  // Confirm import and modification occur in different modules
  not importedMember.getEnclosingModule() = attributeModification.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not attributeModification.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", originalModule,
  "module " + originalModule.getName(), attributeModification, originalModule.getName() + "." + attributeModification.getName()