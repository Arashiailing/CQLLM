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
  // Verify module equivalence through import aliasing
  exists(string moduleName |
    moduleName = importedMember.getModule().(ImportExpr).getImportedModuleName() and
    sourceModule.importedAs(moduleName)
  ) and
  // Mutation must be a write operation
  mutationSite.isStore() and
  // Mutation target must reference the source module
  mutationSite.getObject(attrName).pointsTo(sourceModule) and
  // Imported attribute must be module-scoped (not function-local)
  not importedMember.getScope() instanceof Function and
  // Mutation must occur within function scope
  mutationSite.getScope() instanceof Function and
  // Import and mutation must reside in different modules
  not importedMember.getEnclosingModule() = mutationSite.getScope().getEnclosingModule() and
  // Exclude mutations within test code
  not mutationSite.getScope().getScope*() instanceof TestScope
select importedMember,
  "Importing the value of '" + attrName +
    "' from $@ means that any change made to $@ will be not be observed locally.", sourceModule,
  "module " + sourceModule.getName(), mutationSite, sourceModule.getName() + "." + mutationSite.getName()