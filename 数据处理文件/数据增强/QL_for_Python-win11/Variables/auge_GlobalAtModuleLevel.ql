/**
 * @name Use of 'global' at module level
 * @description Use of the 'global' statement at module level
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python language module for code analysis and AST traversal
import python

// Identify global variable declarations that occur at module scope
from Global redundantGlobalDecl
where 
  // Restrict analysis to global declarations in module context only
  redundantGlobalDecl.getScope() instanceof Module
select 
  redundantGlobalDecl, 
  // Construct warning message highlighting the redundant global usage
  "Declaring '" + redundantGlobalDecl.getAName() + "' as global at module-level is redundant."