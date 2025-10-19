/**
 * @name Importing value of mutable attribute
 * @description Detects direct imports of mutable attribute values which prevent local observation of global state changes.
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

from ImportMember importedAttr, ModuleValue sourceModule, AttrNode attrMod, string attributeName
where
  // Verify attribute name consistency between import and modification
  importedAttr.getName() = attributeName and
  // Ensure modification targets the imported module
  attrMod.getObject(attributeName).pointsTo(sourceModule) and
  // Confirm module origin matches import source
  sourceModule.importedAs(importedAttr.getModule().(ImportExpr).getImportedModuleName()) and
  // Validate modification is a store operation
  attrMod.isStore() and
  // Verify scope constraints:
  // 1. Imported attribute exists at module level (non-function scope)
  not importedAttr.getScope() instanceof Function and
  // 2. Modification occurs within function scope
  attrMod.getScope() instanceof Function and
  // 3. Import and modification originate from different modules
  not importedAttr.getEnclosingModule() = attrMod.getScope().getEnclosingModule() and
  // Exclude test code modifications
  not attrMod.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), attrMod, sourceModule.getName() + "." + attributeName