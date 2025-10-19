/**
 * @name Import of mutable attribute value
 * @description Identifies when a mutable attribute is imported directly, which can lead to issues where local code does not observe changes to the global state.
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

from ImportMember importedMember, ModuleValue srcModule, AttrNode modifiedAttr, string attrName
where
  // Attribute name consistency between import and modification
  importedMember.getName() = attrName and
  // Modification targets the imported module
  modifiedAttr.getObject(attrName).pointsTo(srcModule) and
  // Module origin matches import source
  srcModule.importedAs(importedMember.getModule().(ImportExpr).getImportedModuleName()) and
  // Modification is a store operation
  modifiedAttr.isStore() and
  // Scope validation:
  (
    // Imported attribute exists at module level
    not importedMember.getScope() instanceof Function and
    // Modification occurs within function scope
    modifiedAttr.getScope() instanceof Function and
    // Import and modification originate from different modules
    not importedMember.getEnclosingModule() = modifiedAttr.getScope().getEnclosingModule()
  ) and
  // Exclude test code modifications
  not modifiedAttr.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", srcModule,
  "module " + srcModule.getName(), modifiedAttr, srcModule.getName() + "." + attrName