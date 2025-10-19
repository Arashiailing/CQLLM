/**
 * @name Empty except
 * @description Detects except clauses that do nothing without explanatory comments
 * @kind problem
 * @tags reliability
 *       maintainability
 * @external/cwe/cwe-390
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/empty-except
 */

import python
import semmle.python.ApiGraphs

// Determines if an except block contains only pass statements
predicate isExceptBlockEmpty(ExceptStmt exceptHandler) {
  // Check that the except block contains no non-pass statements
  not exists(Stmt statement | statement = exceptHandler.getAStmt() and not statement instanceof Pass)
}

// Checks if an except statement lacks an else clause
predicate isElseClauseAbsent(ExceptStmt exceptHandler) { 
  // Ensure that the try statement does not have an associated else block
  not exists(exceptHandler.getTry().getOrelse()) 
}

// Identifies except blocks without associated comments
predicate isCommentAbsent(ExceptStmt exceptHandler) {
  // Confirm that no comments exist within the except block's scope
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptHandler.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptHandler.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptHandler.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Detects except handlers for non-local control flow exceptions
predicate handlesControlFlowException(ExceptStmt exceptHandler) {
  // Verify if the exception type is StopIteration
  exceptHandler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Verifies if a try block has normal execution paths
predicate hasNormalExecutionPath(Try tryBlock) {
  // Search for non-exceptional control flow transitions
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    /* Non-exceptional edge exists between nodes */
    predecessor.getASuccessor() = successor and
    not predecessor.getAnExceptionalSuccessor() = successor
  |
    /* Successor is not a return node */
    not exists(Scope scope | scope.getReturnNode() = successor) and
    /* Predecessor is in try block, successor is outside */
    predecessor.getNode().getParentNode*() = tryBlock.getAStmt() and
    not successor.getNode().getParentNode*() = tryBlock.getAStmt()
  )
}

// Checks if a statement involves attribute access
predicate containsAttributeAccess(Stmt codeStatement) {
  // Attribute access in expression statements
  codeStatement.(ExprStmt).getValue() instanceof Attribute
  or
  // Attribute access via built-in functions
  exists(string functionName | codeStatement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = functionName |
    functionName in ["getattr", "setattr", "delattr"]
  )
  or
  // Attribute deletion
  codeStatement.(Delete).getATarget() instanceof Attribute
}

// Identifies subscript operations in statements
predicate containsSubscriptOperation(Stmt codeStatement) {
  // Subscript access in expressions
  codeStatement.(ExprStmt).getValue() instanceof Subscript
  or
  // Subscript deletion
  codeStatement.(Delete).getATarget() instanceof Subscript
}

// Detects encoding/decoding operations with specific exception types
predicate isEncodingDecodingCall(Call functionCall, Expr exceptionType) {
  // Verify function name and match corresponding exception type
  exists(string operationName | functionCall.getFunc().(Attribute).getName() = operationName |
    (operationName = "encode" and
     exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (operationName = "decode" and
     exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Identifies handlers targeting specific exception types with minimal handling
predicate isTargetedExceptionHandler(ExceptStmt exceptHandler, Stmt codeStatement, Expr exceptionType) {
  // Single-statement try block with specific exception type
  not exists(exceptHandler.getTry().getStmt(1)) and
  codeStatement = exceptHandler.getTry().getStmt(0) and
  exceptHandler.getType() = exceptionType
}

// Detects focused exception handlers for specific error scenarios
predicate isSpecializedHandler(ExceptStmt exceptHandler) {
  // Check for targeted exception handling patterns
  exists(Stmt codeStatement, Expr exceptionType | isTargetedExceptionHandler(exceptHandler, codeStatement, exceptionType) |
    // IndexError for subscript operations
    (containsSubscriptOperation(codeStatement) and
     exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError for attribute access
    (containsAttributeAccess(codeStatement) and
     exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError for name references
    (codeStatement.(ExprStmt).getValue() instanceof Name and
     exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding errors
    isEncodingDecodingCall(codeStatement.(ExprStmt).getValue(), exceptionType)
  )
}

// Identifies try blocks that contain return statements
predicate containsReturnStatement(Try tryBlock) {
  exists(Return returnStatement | returnStatement.getParentNode*() = tryBlock)
}

// Main query for detecting problematic empty except blocks
from ExceptStmt exceptHandler
where
  // Identify empty except blocks without explanations
  isExceptBlockEmpty(exceptHandler) and
  isElseClauseAbsent(exceptHandler) and
  isCommentAbsent(exceptHandler) and
  // Exclude non-local control flow handlers
  not handlesControlFlowException(exceptHandler) and
  // Exclude try-return constructs
  not containsReturnStatement(exceptHandler.getTry()) and
  // Verify normal execution paths exist
  hasNormalExecutionPath(exceptHandler.getTry()) and
  // Exclude focused exception handlers
  not isSpecializedHandler(exceptHandler)
select exceptHandler, "'except' clause does nothing but pass and there is no explanatory comment."