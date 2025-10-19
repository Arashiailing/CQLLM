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

// Predicate to identify except blocks containing only pass statements
predicate is_empty_except(ExceptStmt exceptBlock) {
  // Verify all statements in except block are pass statements
  not exists(Stmt stmt | 
    stmt = exceptBlock.getAStmt() and 
    not stmt instanceof Pass
  )
}

// Predicate to detect absence of else clause in try-except
predicate has_no_else_clause(ExceptStmt exceptBlock) { 
  // Confirm try statement has no else block
  not exists(exceptBlock.getTry().getOrelse()) 
}

// Predicate to check for missing explanatory comments
predicate lacks_explanatory_comment(ExceptStmt exceptBlock) {
  // Ensure no comments exist within except block boundaries
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptBlock.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptBlock.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptBlock.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Predicate to identify non-local control flow exceptions
predicate handles_non_local_flow(ExceptStmt exceptBlock) {
  // Check for StopIteration exception handling
  exceptBlock.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Predicate to verify normal execution exits from try block
predicate has_normal_exit_path(Try tryBlock) {
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

// Predicate to detect attribute access operations
predicate involves_attribute_access(Stmt statement) {
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

// Predicate to detect subscript operations
predicate involves_subscript_operation(Stmt statement) {
  // Subscript access or deletion
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  statement.(Delete).getATarget() instanceof Subscript
}

// Predicate to identify encode/decode operations
predicate is_encoding_decoding_call(Call callExpr, Expr exceptionType) {
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

// Predicate to identify single-statement exception handlers
predicate is_single_statement_handler(ExceptStmt exceptBlock, Stmt statement, Expr exceptionType) {
  // Verify try block contains exactly one statement
  not exists(exceptBlock.getTry().getStmt(1)) and
  statement = exceptBlock.getTry().getStmt(0) and
  exceptBlock.getType() = exceptionType
}

// Predicate to detect focused exception handlers
predicate is_focused_handler(ExceptStmt exceptBlock) {
  // Check for specific exception handling patterns
  exists(Stmt statement, Expr exceptionType | 
    is_single_statement_handler(exceptBlock, statement, exceptionType) |
    // Subscript operations with IndexError
    involves_subscript_operation(statement) and
    exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    involves_attribute_access(statement) and
    exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    statement.(ExprStmt).getValue() instanceof Name and
    exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    is_encoding_decoding_call(statement.(ExprStmt).getValue(), exceptionType)
  )
}

// Main query to identify problematic empty except blocks
from ExceptStmt exceptBlock
where
  // Core conditions: empty except block without else clause or comments
  is_empty_except(exceptBlock) and
  has_no_else_clause(exceptBlock) and
  lacks_explanatory_comment(exceptBlock) and
  // Exclude non-local control flow handlers
  not handles_non_local_flow(exceptBlock) and
  // Ensure try block has normal execution path
  has_normal_exit_path(exceptBlock.getTry()) and
  // Exclude focused exception handlers
  not is_focused_handler(exceptBlock)
select exceptBlock, "'except' clause does nothing but pass and there is no explanatory comment."