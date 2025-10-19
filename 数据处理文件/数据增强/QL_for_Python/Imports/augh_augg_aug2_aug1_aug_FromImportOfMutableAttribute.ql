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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attrAssignment, string attrName
where
  // Ensure imported attribute matches modified attribute name
  importedAttr.getName() = attrName and
  
  // Verify source module matches the origin of imported module
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Confirm attribute modification is a store operation
  attrAssignment.isStore() and
  // Ensure modification targets source module's attribute
  attrAssignment.getObject(attrName).pointsTo(sourceModule) and
  
  // Validate attribute has module-level scope in import context
  not importedAttr.getScope() instanceof Function and
  // Ensure modification occurs within function scope
  attrAssignment.getScope() instanceof Function and
  
  // Verify import and modification occur in different modules
  not importedAttr.getEnclosingModule() = attrAssignment.getScope().getEnclosingModule() and
  // Exclude modifications within test code
  not attrAssignment.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrAssignment, sourceModule.getName() + "." + attrAssignment.getName()