/**
 * @name Empty except
 * @description Except clause contains only pass statement without explanatory comment
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-390
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/empty-except
 */

import python
import semmle.python.ApiGraphs

// Check if except block contains only pass statements
predicate contains_only_pass(ExceptStmt handler) {
  // Verify all statements in except block are pass statements
  not exists(Stmt stmt | 
    stmt = handler.getAStmt() and 
    not stmt instanceof Pass
  )
}

// Check if try statement lacks else clause
predicate missing_else_clause(ExceptStmt handler) { 
  // Confirm try statement has no else block
  not exists(handler.getTry().getOrelse()) 
}

// Check if except block lacks explanatory comments
predicate no_explanatory_comment(ExceptStmt handler) {
  // Ensure no comments exist within except block boundaries
  not exists(Comment comment |
    comment.getLocation().getFile() = handler.getLocation().getFile() and
    comment.getLocation().getStartLine() >= handler.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= handler.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Check if except block handles non-local control flow exceptions
predicate handles_control_flow_exception(ExceptStmt handler) {
  // Check for StopIteration exception handling
  handler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Check if try block has normal execution exit path
predicate normal_execution_exit(Try tryBlock) {
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

// Check if statement involves attribute access
predicate has_attribute_access(Stmt statement) {
  // Direct attribute access or getattr/setattr/delattr calls
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string methodName | 
    statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = methodName |
    methodName = "getattr" or methodName = "setattr" or methodName = "delattr"
  )
  or
  statement.(Delete).getATarget() instanceof Attribute
}

// Check if statement involves subscript operation
predicate has_subscript_operation(Stmt statement) {
  // Subscript access or deletion
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  statement.(Delete).getATarget() instanceof Subscript
}

// Check if call is an encode/decode operation with corresponding exception type
predicate is_encode_decode_call(Call callExpr, Expr exceptionType) {
  // Match encode/decode calls with corresponding exception types
  exists(string operationName | 
    callExpr.getFunc().(Attribute).getName() = operationName |
    operationName = "encode" and
    exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    operationName = "decode" and
    exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

// Check if except block handles a single statement in try block
predicate single_statement_handler(ExceptStmt handler, Stmt statement, Expr exceptionType) {
  // Verify try block contains exactly one statement
  not exists(handler.getTry().getStmt(1)) and
  statement = handler.getTry().getStmt(0) and
  handler.getType() = exceptionType
}

// Check if except block is a focused handler for specific exception types
predicate focused_exception_handler(ExceptStmt handler) {
  // Check for specific exception handling patterns
  exists(Stmt statement, Expr exceptionType | 
    single_statement_handler(handler, statement, exceptionType) |
    // Subscript operations with IndexError
    has_subscript_operation(statement) and
    exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    has_attribute_access(statement) and
    exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    statement.(ExprStmt).getValue() instanceof Name and
    exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    is_encode_decode_call(statement.(ExprStmt).getValue(), exceptionType)
  )
}

// Main query to identify problematic empty except blocks
from ExceptStmt handler
where
  // Core conditions: empty except block without else clause or comments
  contains_only_pass(handler) and
  missing_else_clause(handler) and
  no_explanatory_comment(handler) and
  // Exclude non-local control flow handlers
  not handles_control_flow_exception(handler) and
  // Ensure try block has normal execution path
  normal_execution_exit(handler.getTry()) and
  // Exclude focused exception handlers
  not focused_exception_handler(handler)
select handler, "'except' clause does nothing but pass and there is no explanatory comment."