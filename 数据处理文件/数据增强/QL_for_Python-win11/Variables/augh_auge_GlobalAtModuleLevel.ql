/**
 * @name Use of 'global' at module level
 * @description Identifies redundant 'global' statements at module scope where variables are global by default
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python language support for AST analysis and code inspection
import python

// Find global declarations that appear in module scope
from Global moduleLevelGlobal
where 
  // Filter for global declarations located specifically at module level
  moduleLevelGlobal.getScope() instanceof Module
select 
  moduleLevelGlobal, 
  // Generate alert message explaining the redundancy of module-level global declarations
  "Declaring '" + moduleLevelGlobal.getAName() + "' as global at module-level is redundant."