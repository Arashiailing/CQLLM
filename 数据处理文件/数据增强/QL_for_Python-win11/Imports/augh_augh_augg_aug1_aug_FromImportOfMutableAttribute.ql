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

from ImportMember importedAttr, ModuleValue sourceMod, AttrNode mutationPoint, string attributeName
where
  // Attribute name consistency between import and mutation
  importedAttr.getName() = attributeName and
  // Module equivalence verification through import aliasing
  exists(string moduleName |
    moduleName = importedAttr.getModule().(ImportExpr).getImportedModuleName() and
    sourceMod.importedAs(moduleName)
  ) and
  // Mutation must be a write operation
  mutationPoint.isStore() and
  // Mutation target references the source module
  mutationPoint.getObject(attributeName).pointsTo(sourceMod) and
  // Imported attribute must be module-scoped (not function-local)
  not importedAttr.getScope() instanceof Function and
  // Mutation must occur within function scope
  mutationPoint.getScope() instanceof Function and
  // Import and mutation must reside in different modules
  not importedAttr.getEnclosingModule() = mutationPoint.getScope().getEnclosingModule() and
  // Exclude mutations within test code
  not mutationPoint.getScope().getScope*() instanceof TestScope
select importedAttr,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceMod,
  "module " + sourceMod.getName(), mutationPoint, sourceMod.getName() + "." + mutationPoint.getName()