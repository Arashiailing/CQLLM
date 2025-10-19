/**
 * @name Expression fails to point-to an object
 * @description Identifies Python expressions that do not reference any object,
 *              which can prevent proper type inference and analysis.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import necessary Python modules for code analysis
import python

// Find expressions that have at least one control flow node which doesn't reference any object
from Expr expr
where exists(ControlFlowNode cfNode | 
    cfNode = expr.getAFlowNode() and 
    not cfNode.refersTo(_)
)
// Report the expression with a descriptive message
select expr, "Expression does not 'point-to' any object."