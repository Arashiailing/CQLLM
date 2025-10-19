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

from ImportMember importedMember, ModuleValue originModule, AttrNode attrAssignment, string attributeName
where
  // Attribute name consistency check
  importedMember.getName() = attributeName and
  
  // Module import relationship verification
  originModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  
  // Attribute modification operation validation
  attrAssignment.isStore() and
  attrAssignment.getObject(attributeName).pointsTo(originModule) and
  
  // Scope constraints for import and modification
  not importedMember.getScope() instanceof Function and  // Module-level import
  attrAssignment.getScope() instanceof Function and      // Function-level modification
  not importedMember.getEnclosingModule() = attrAssignment.getScope().getEnclosingModule() and  // Cross-module
  
  // Test code exclusion
  not attrAssignment.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", originModule,
  "module " + originModule.getName(), attrAssignment, originModule.getName() + "." + attrAssignment.getName()