/**
 * @name Detection of 'global' keyword usage.
 * @description Identifies instances where 'global' statements are used, potentially indicating suboptimal modular design patterns.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global statements that are not at module level.
// Using global variables outside of module initialization can make code harder to understand and maintain.
from Global globalStatement
where 
  // Exclude global statements that are at module level, as these are generally acceptable
  not globalStatement.getScope() instanceof Module
select globalStatement, "Modifying global variables outside of module initialization is not recommended."