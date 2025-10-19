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

from ImportMember importedMember, ModuleValue sourceModule, AttrNode attributeModification, string attributeName
where
  // Validate module name consistency between import and source
  sourceModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Ensure imported member name matches modified attribute name
  importedMember.getName() = attributeName and
  
  // Verify attribute modification occurs within function scope
  exists(Function modifyingFunction | attributeModification.getScope() = modifyingFunction) and
  
  // Confirm imported member has module-level scope (not function-level)
  not exists(Function func | importedMember.getScope() = func) and
  
  // Ensure attribute modification is a store operation
  attributeModification.isStore() and
  
  // Verify modified attribute references the source module
  attributeModification.getObject(attributeName).pointsTo(sourceModule) and
  
  // Ensure import and modification occur in different modules
  importedMember.getEnclosingModule() != attributeModification.getScope().getEnclosingModule() and
  
  // Exclude modifications within test code
  not exists(TestScope testScope | attributeModification.getScope().getScope*() = testScope)
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attributeModification, sourceModule.getName() + "." + attributeModification.getName()