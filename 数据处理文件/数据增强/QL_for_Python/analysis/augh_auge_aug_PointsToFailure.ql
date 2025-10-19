/**
 * @name points-to fails for expression.
 * @description Identifies Python expressions that fail to point-to any object, 
 *              which prevents type inference systems from determining their types.
 *              This query helps debug type inference issues by locating expressions
 *              that don't have a defined point-to set. When an expression cannot
 *              be resolved to point to any object, type inference becomes impossible.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import Python analysis library for static code analysis capabilities
import python

// Find expressions with points-to analysis failure
from Expr problematicExpr
where 
    // An expression has points-to failure if it has a control flow node 
    // that doesn't refer to any object
    exists(ControlFlowNode cfNode | 
        cfNode = problematicExpr.getAFlowNode() and 
        not cfNode.refersTo(_)
    )
// Output the expression node with a descriptive message
select problematicExpr, "Expression does not 'point-to' any object."