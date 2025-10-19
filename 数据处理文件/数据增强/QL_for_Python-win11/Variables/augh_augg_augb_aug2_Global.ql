/**
 * @name Usage of 'global' keyword in Python code.
 * @description Identifies instances where 'global' statements are used within non-module scopes,
 *              which can lead to code that is difficult to maintain and understand due to
 *              implicit dependencies between function code and global state.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Find all global variable declarations in the Python codebase
from Global globalDecl
// Exclude global declarations that are at the module level, as these represent
// proper module initialization patterns which are acceptable
where not globalDecl.getScope() instanceof Module
// Report global declarations found within functions or other non-module scopes,
// as they may indicate poor encapsulation and make code harder to reason about
select globalDecl, "Usage of 'global' keyword in non-module scope can reduce code maintainability and clarity."