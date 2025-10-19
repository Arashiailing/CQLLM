/**
 * @name Detection of non-module global variable usage.
 * @description Identifies instances where the 'global' keyword is used outside of module scope,
 *              which can lead to code that is difficult to maintain and understand.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Define the source: all global variable declarations
from Global globalDeclaration
// Define the condition: global variable must be outside module scope
where not globalDeclaration.getScope() instanceof Module
// Define the output: the global variable and a warning message
select globalDeclaration, "Modifying global variables outside of module initialization is considered a bad practice."