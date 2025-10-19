/**
 * @name Importing value of mutable attribute
 * @description Detects direct imports of mutable attribute values, which prevents local observation of global state changes.
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

from ImportMember importedAttr, ModuleValue srcModule, AttrNode writeNode, string attributeName
where
  // Ensure attribute name consistency between import and mutation operations
  importedAttr.getName() = attributeName and
  // Verify module equivalence through import aliasing mechanism
  exists(string moduleName |
    moduleName = importedAttr.getModule().(ImportExpr).getImportedModuleName() and
    srcModule.importedAs(moduleName)
  ) and
  // Mutation must be a write operation targeting the source module
  writeNode.isStore() and
  writeNode.getObject(attributeName).pointsTo(srcModule) and
  // Validate scope constraints: module-level import and function-level mutation
  not importedAttr.getScope() instanceof Function and
  writeNode.getScope() instanceof Function and
  // Ensure import and mutation occur in different modules
  not importedAttr.getEnclosingModule() = writeNode.getScope().getEnclosingModule() and
  // Exclude mutations within test code scope
  not writeNode.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", srcModule,
  "module " + srcModule.getName(), writeNode, srcModule.getName() + "." + writeNode.getName()