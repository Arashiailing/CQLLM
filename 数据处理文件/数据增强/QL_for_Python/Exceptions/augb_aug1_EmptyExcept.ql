/**
 * @name Empty except
 * @description Identifies except blocks containing only pass statements without explanatory comments
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/empty-except
 */

import python
import semmle.python.ApiGraphs

// Identifies except blocks containing exclusively pass statements
predicate contains_only_pass(ExceptStmt exceptBlock) {
  // Verify all statements within except block are pass statements
  not exists(Stmt stmt | 
    stmt = exceptBlock.getAStmt() and 
    not stmt instanceof Pass
  )
}

// Detects absence of else clause in try-except constructs
predicate missing_else_clause(ExceptStmt exceptBlock) { 
  // Confirm try statement lacks else block
  not exists(exceptBlock.getTry().getOrelse()) 
}

// Checks for absence of explanatory comments within except blocks
predicate no_explanatory_comment(ExceptStmt exceptBlock) {
  // Ensure no comments exist within except block boundaries
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptBlock.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptBlock.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptBlock.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Identifies handlers for non-local control flow exceptions
predicate handles_control_flow_exception(ExceptStmt exceptBlock) {
  // Check for StopIteration exception handling
  exceptBlock.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Verifies normal execution exits from try block
predicate has_non_exceptional_exit(Try tryBlock) {
  // Find non-exceptional control flow transitions
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    /* Normal (non-exceptional) control flow edge */
    predecessor.getASuccessor() = successor and
    not predecessor.getAnExceptionalSuccessor() = successor
  |
    /* Valid successor: not a return node */
    not exists(Scope scope | scope.getReturnNode() = successor) and
    /* Predecessor in try body, successor outside */
    predecessor.getNode().getParentNode*() = tryBlock.getAStmt() and
    not successor.getNode().getParentNode*() = tryBlock.getAStmt()
  )
}

// Detects attribute access operations in statements
predicate contains_attribute_access(Stmt stmt) {
  // Direct attribute access or getattr/setattr/delattr calls
  stmt.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string methodName | 
    stmt.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = methodName |
    methodName = "getattr" or methodName = "setattr" or methodName = "delattr"
  )
  or
  stmt.(Delete).getATarget() instanceof Attribute
}

// Detects subscript operations in statements
predicate contains_subscript_operation(Stmt stmt) {
  // Subscript access or deletion
  stmt.(ExprStmt).getValue() instanceof Subscript
  or
  stmt.(Delete).getATarget() instanceof Subscript
}

// Identifies encode/decode operations with corresponding exception types
predicate is_codec_operation(Call callExpr, Expr exceptionType) {
  // Match encode/decode calls with corresponding exception types
  exists(string opName | 
    callExpr.getFunc().(Attribute).getName() = opName |
    opName = "encode" and
    exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    opName = "decode" and
    exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

// Identifies single-statement exception handlers
predicate is_single_stmt_handler(ExceptStmt exceptBlock, Stmt stmt, Expr exceptionType) {
  // Verify try block contains exactly one statement
  not exists(exceptBlock.getTry().getStmt(1)) and
  stmt = exceptBlock.getTry().getStmt(0) and
  exceptBlock.getType() = exceptionType
}

// Detects focused exception handlers for specific operations
predicate is_specialized_handler(ExceptStmt exceptBlock) {
  // Check for specific exception handling patterns
  exists(Stmt stmt, Expr exceptionType | 
    is_single_stmt_handler(exceptBlock, stmt, exceptionType) |
    // Subscript operations with IndexError
    contains_subscript_operation(stmt) and
    exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    contains_attribute_access(stmt) and
    exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    stmt.(ExprStmt).getValue() instanceof Name and
    exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    is_codec_operation(stmt.(ExprStmt).getValue(), exceptionType)
  )
}

// Main query to identify problematic empty except blocks
from ExceptStmt exceptBlock
where
  // Core conditions: empty except block without else clause or comments
  contains_only_pass(exceptBlock) and
  missing_else_clause(exceptBlock) and
  no_explanatory_comment(exceptBlock) and
  // Exclude non-local control flow handlers
  not handles_control_flow_exception(exceptBlock) and
  // Ensure try block has normal execution path
  has_non_exceptional_exit(exceptBlock.getTry()) and
  // Exclude specialized exception handlers
  not is_specialized_handler(exceptBlock)
select exceptBlock, "'except' clause does nothing but pass and there is no explanatory comment."