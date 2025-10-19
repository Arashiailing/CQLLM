/**
 * @name Use of 'global' at module level
 * @description Identifies redundant 'global' declarations at module scope where they have no effect
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python module for code parsing and analysis
import python

// Query for global declarations that appear at module level
from Global globalDeclaration
where 
  // Filter to only include global declarations whose scope is a module
  // Such declarations are redundant since module-level variables are already global
  globalDeclaration.getScope() instanceof Module
select 
  globalDeclaration, 
  // Construct warning message about the redundant global declaration
  "Declaring '" + globalDeclaration.getAName() + "' as global at module-level is redundant."