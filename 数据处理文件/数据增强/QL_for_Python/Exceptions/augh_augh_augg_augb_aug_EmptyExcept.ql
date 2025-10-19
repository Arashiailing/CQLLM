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

// Determines if an except block consists solely of pass statements
predicate isExceptBlockEmpty(ExceptStmt exceptClause) {
  // Verify that the except block contains only pass statements
  not exists(Stmt statement | statement = exceptClause.getAStmt() and not statement instanceof Pass)
}

// Verifies that an except statement does not have an associated else clause
predicate isElseClauseAbsent(ExceptStmt exceptClause) { 
  // Confirm that the try statement lacks an else block
  not exists(exceptClause.getTry().getOrelse()) 
}

// Identifies except blocks that are not accompanied by explanatory comments
predicate isCommentAbsent(ExceptStmt exceptClause) {
  // Ensure no comments are present within the except block's range
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptClause.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptClause.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptClause.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Detects except handlers that manage non-local control flow exceptions
predicate handlesControlFlowException(ExceptStmt exceptClause) {
  // Check if the exception type is StopIteration
  exceptClause.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Evaluates whether a try block has normal execution paths
predicate hasNormalExecutionPath(Try tryBlock) {
  // Look for non-exceptional control flow transitions
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    /* Non-exceptional edge between nodes exists */
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

// Determines if a statement involves attribute access operations
predicate containsAttributeAccess(Stmt statement) {
  // Attribute access in expression statements
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  // Attribute access via built-in functions
  exists(string functionName | statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = functionName |
    functionName in ["getattr", "setattr", "delattr"]
  )
  or
  // Attribute deletion operations
  statement.(Delete).getATarget() instanceof Attribute
}

// Identifies subscript operations within statements
predicate containsSubscriptOperation(Stmt statement) {
  // Subscript access in expressions
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  // Subscript deletion
  statement.(Delete).getATarget() instanceof Subscript
}

// Detects encoding/decoding function calls with specific exception types
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
predicate isTargetedExceptionHandler(ExceptStmt exceptClause, Stmt statement, Expr exceptionType) {
  // Single-statement try block with specific exception type
  not exists(exceptClause.getTry().getStmt(1)) and
  statement = exceptClause.getTry().getStmt(0) and
  exceptClause.getType() = exceptionType
}

// Detects focused exception handlers for particular error scenarios
predicate isSpecializedHandler(ExceptStmt exceptClause) {
  // Check for targeted exception handling patterns
  exists(Stmt statement, Expr exceptionType | isTargetedExceptionHandler(exceptClause, statement, exceptionType) |
    // IndexError for subscript operations
    (containsSubscriptOperation(statement) and
     exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError for attribute access
    (containsAttributeAccess(statement) and
     exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError for name references
    (statement.(ExprStmt).getValue() instanceof Name and
     exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding errors
    isEncodingDecodingCall(statement.(ExprStmt).getValue(), exceptionType)
  )
}

// Identifies try blocks that include return statements
predicate containsReturnStatement(Try tryBlock) {
  exists(Return returnStatement | returnStatement.getParentNode*() = tryBlock)
}

// Main query for detecting problematic empty except blocks
from ExceptStmt exceptClause
where
  // Identify empty except blocks without explanations
  isExceptBlockEmpty(exceptClause) and
  isElseClauseAbsent(exceptClause) and
  isCommentAbsent(exceptClause) and
  // Exclude non-local control flow handlers
  not handlesControlFlowException(exceptClause) and
  // Exclude try-return constructs
  not containsReturnStatement(exceptClause.getTry()) and
  // Verify normal execution paths exist
  hasNormalExecutionPath(exceptClause.getTry()) and
  // Exclude focused exception handlers
  not isSpecializedHandler(exceptClause)
select exceptClause, "'except' clause does nothing but pass and there is no explanatory comment."