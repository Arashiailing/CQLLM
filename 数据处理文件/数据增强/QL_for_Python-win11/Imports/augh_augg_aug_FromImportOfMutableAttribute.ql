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

from ImportMember importedAttribute, ModuleValue sourceModule, AttrNode attributeAssignment, string attributeName
where
  // Verify imported module reference matches actual module
  sourceModule.importedAs(importedAttribute.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure consistent attribute naming between import and modification
  importedAttribute.getName() = attributeName and
  // Confirm attribute assignment occurs within function scope
  attributeAssignment.getScope() instanceof Function and
  // Validate imported attribute originates from module-level scope
  not importedAttribute.getScope() instanceof Function and
  // Verify assignment operation performs attribute modification
  attributeAssignment.isStore() and
  // Confirm assignment targets the imported module's attribute
  attributeAssignment.getObject(attributeName).pointsTo(sourceModule) and
  // Ensure import and modification occur in separate modules
  not importedAttribute.getEnclosingModule() = attributeAssignment.getScope().getEnclosingModule() and
  // Exclude modifications within test code boundaries
  not attributeAssignment.getScope().getScope*() instanceof TestScope
select importedAttribute,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attributeAssignment, sourceModule.getName() + "." + attributeName