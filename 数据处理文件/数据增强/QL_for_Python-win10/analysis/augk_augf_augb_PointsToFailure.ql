/**
 * @name Expression points-to analysis failure
 * @description Identifies expressions that fail to point-to any object,
 *              which prevents proper type inference in the codebase.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import the Python library for code analysis
import python

from Expr expressionWithoutTarget
where 
    // Check if the expression has no corresponding control flow node
    // that refers to any object
    not exists(ControlFlowNode controlFlowNode | 
        controlFlowNode = expressionWithoutTarget.getAFlowNode() and 
        controlFlowNode.refersTo(_)
    )
select expressionWithoutTarget, "Expression does not 'point-to' any object."