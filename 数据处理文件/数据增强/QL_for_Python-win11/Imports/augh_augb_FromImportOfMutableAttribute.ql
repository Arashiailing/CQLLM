/**
 * @name Importing value of mutable attribute
 * @description Detects direct imports of mutable attribute values, which can cause inconsistencies
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

// Import necessary Python libraries and test filters
import python
import semmle.python.filters.Tests

// Identify cases where a mutable attribute is imported and then modified
from ImportMember importedMember, ModuleValue sourceModule, AttrNode attrAssignment, string attrName
where
  // Verify the imported module matches the source module and the names match
  sourceModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  importedMember.getName() = attrName and
  
  // Check scope conditions: attribute modified in function, imported at module level
  attrAssignment.getScope() instanceof Function and
  not importedMember.getScope() instanceof Function and
  
  // Verify this is a store operation and the attribute points to the imported module
  attrAssignment.isStore() and
  attrAssignment.getObject(attrName).pointsTo(sourceModule) and
  
  // Ensure import and modification are in different modules and not in test code
  not importedMember.getEnclosingModule() = attrAssignment.getScope().getEnclosingModule() and
  not attrAssignment.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrAssignment, sourceModule.getName() + "." + attrAssignment.getName()