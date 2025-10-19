/**
 * @name Importing value of mutable attribute
 * @description Detects when a mutable attribute's value is directly imported, which can cause inconsistencies
 *              because local copies won't reflect subsequent changes in the global state.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity high
 * @precision medium
 * @id py/import-of-mutable-attribute
 */

// Import required Python libraries and test filters
import python
import semmle.python.filters.Tests

// Identify mutable attribute imports and their subsequent modifications
from ImportMember importedMember, ModuleValue sourceModule, AttrNode modifiedAttribute, string targetAttributeName
where
  // Verify that the imported module matches the source module
  sourceModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Ensure the imported member name matches the target attribute name
  importedMember.getName() = targetAttributeName and
  // Confirm that attribute modification occurs within a function scope
  modifiedAttribute.getScope() instanceof Function and
  // Ensure the imported variable has module-level lifecycle (not function-scoped)
  not importedMember.getScope() instanceof Function and
  // Verify this is an attribute store operation (assignment)
  modifiedAttribute.isStore() and
  // Confirm the attribute object points to the imported module
  modifiedAttribute.getObject(targetAttributeName).pointsTo(sourceModule) and
  // Ensure import and modification occur in different modules
  not importedMember.getEnclosingModule() = modifiedAttribute.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not modifiedAttribute.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + targetAttributeName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), modifiedAttribute, sourceModule.getName() + "." + modifiedAttribute.getName()