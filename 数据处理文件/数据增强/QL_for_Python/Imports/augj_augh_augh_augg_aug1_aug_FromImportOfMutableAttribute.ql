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

from ImportMember importedMember, ModuleValue sourceModule, AttrNode mutationSite, string attrName
where
  // Attribute name consistency between import and mutation
  importedMember.getName() = attrName and
  // Imported attribute must be module-scoped (not function-local)
  not importedMember.getScope() instanceof Function and
  // Mutation must be a write operation within function scope
  mutationSite.isStore() and
  mutationSite.getScope() instanceof Function and
  // Import and mutation must reside in different modules
  not importedMember.getEnclosingModule() = mutationSite.getScope().getEnclosingModule() and
  // Mutation target references the source module
  mutationSite.getObject(attrName).pointsTo(sourceModule) and
  // Module equivalence verification through import aliasing
  exists(string importedModuleName |
    importedModuleName = importedMember.getModule().(ImportExpr).getImportedModuleName() and
    sourceModule.importedAs(importedModuleName)
  ) and
  // Exclude mutations within test code
  not mutationSite.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), mutationSite, sourceModule.getName() + "." + mutationSite.getName()