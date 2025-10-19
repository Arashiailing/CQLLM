/**
 * @name String concatenation in loop
 * @description Detects inefficient string concatenation inside loops causing quadratic performance.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// Identifies binary expressions performing string concatenation that occur within loops
// The loop detection is inferred through SSA variable relationships rather than explicit loop constructs
predicate string_concat_in_loop(BinaryExpr stringConcatOp) {
  // Verify the operation is string concatenation using the addition operator
  stringConcatOp.getOp() instanceof Add and
  
  // Analyze SSA variables involved in the concatenation pattern
  exists(SsaVariable targetSsaVar, SsaVariable sourceSsaVar, BinaryExprNode concatNode |
    // Connect the binary expression to its AST representation
    concatNode.getNode() = stringConcatOp and 
    
    // Establish SSA relationship: targetSsaVar is the ultimate definition of sourceSsaVar
    targetSsaVar = sourceSsaVar.getAnUltimateDefinition() and
    
    // Ensure the definition originates from this concatenation operation
    targetSsaVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    
    // Confirm the variable is used as an operand in the concatenation
    sourceSsaVar.getAUse() = concatNode.getAnOperand() and
    
    // Validate that the operand resolves to Python's string type
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// Main query to identify statements containing inefficient string concatenation patterns
from BinaryExpr stringConcatOp, Stmt enclosingStmt
where 
  // Apply our predicate to identify problematic concatenation operations
  string_concat_in_loop(stringConcatOp) and
  
  // Locate the statement that contains the inefficient operation
  enclosingStmt.getASubExpression() = stringConcatOp

// Report findings with a description of the performance implications
select enclosingStmt, "String concatenation in a loop is quadratic in the number of iterations."