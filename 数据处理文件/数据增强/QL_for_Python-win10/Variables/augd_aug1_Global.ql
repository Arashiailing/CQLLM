/**
 * @name Use of the 'global' statement.
 * @description Identifies 'global' statements used outside module scope, potentially indicating poor code modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global statements not defined at module scope, which may indicate poor modularity
from Global globalDeclaration
where not globalDeclaration.getScope() instanceof Module
// Report findings with a warning about discouraged global variable usage
select globalDeclaration, "Updating global variables except at module initialization is discouraged."