/**
 * @name Import shadowed by loop variable
 * @description Detects when a loop variable uses the same identifier as an imported module,
 *              potentially causing confusion and runtime issues due to name collision.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// Import the Python analysis library for examining code structures and relationships
import python

// Define the main query to find loop variables that shadow imported module names
from Variable shadowingVar, Name varDefinition
where 
  // Find an import statement that is being shadowed by our loop variable
  exists(Import importedMod, Name importedAliasName |
    // Condition 1: The imported alias name matches the loop variable identifier
    importedAliasName.getId() = shadowingVar.getId() and
    
    // Condition 2: The alias is explicitly defined via an 'as' clause in the import
    importedAliasName = importedMod.getAName().getAsname() and
    
    // Condition 3: The import's scope contains the variable's scope (hierarchical relationship)
    importedMod.getScope() = shadowingVar.getScope().getScope*() and
    
    // Condition 4: The name definition corresponds to our shadowing variable
    varDefinition.defines(shadowingVar) and
    
    // Condition 5: The definition is used as a target in a for loop (confirming it's a loop variable)
    exists(For forStmt | varDefinition = forStmt.getTarget())
  )
// Output the variable definition node with an appropriate warning message
select varDefinition, "Loop variable '" + shadowingVar.getId() + "' shadows an import."