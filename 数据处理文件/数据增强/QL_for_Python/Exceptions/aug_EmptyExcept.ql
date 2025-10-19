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
predicate isEmptyExcept(ExceptStmt handler) {
  // Verify absence of non-pass statements in the except block
  not exists(Stmt s | s = handler.getAStmt() and not s instanceof Pass)
}

// Checks if an except statement lacks an else clause
predicate lacksElseClause(ExceptStmt handler) { 
  // Confirm the absence of an else block in the try statement
  not exists(handler.getTry().getOrelse()) 
}

// Identifies except blocks without associated comments
predicate hasNoComment(ExceptStmt handler) {
  // Verify no comments exist within the except block's range
  not exists(Comment c |
    c.getLocation().getFile() = handler.getLocation().getFile() and
    c.getLocation().getStartLine() >= handler.getLocation().getStartLine() and
    c.getLocation().getEndLine() <= handler.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Detects except handlers for non-local control flow exceptions
predicate handlesNonLocalControlFlow(ExceptStmt handler) {
  // Check if the exception type is StopIteration
  handler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Verifies if a try block has normal execution paths
predicate hasNormalExitPath(Try tryBlock) {
  // Look for non-exceptional control flow transitions
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    /* Valid non-exceptional edge exists */
    predecessor.getASuccessor() = successor and
    not predecessor.getAnExceptionalSuccessor() = successor
  |
    /* Successor isn't a return node */
    not exists(Scope s | s.getReturnNode() = successor) and
    /* Predecessor is in try block, successor is outside */
    predecessor.getNode().getParentNode*() = tryBlock.getAStmt() and
    not successor.getNode().getParentNode*() = tryBlock.getAStmt()
  )
}

// Checks if a statement involves attribute access
predicate involvesAttributeAccess(Stmt statement) {
  // Attribute access in expression statements
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  // Attribute access via built-in functions
  exists(string name | statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = name |
    name in ["getattr", "setattr", "delattr"]
  )
  or
  // Attribute deletion
  statement.(Delete).getATarget() instanceof Attribute
}

// Identifies subscript operations in statements
predicate involvesSubscriptOperation(Stmt statement) {
  // Subscript access in expressions
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  // Subscript deletion
  statement.(Delete).getATarget() instanceof Subscript
}

// Detects encoding/decoding operations with specific exception types
predicate isEncodeOrDecodeCall(Call operation, Expr exceptionType) {
  // Verify function name and match corresponding exception type
  exists(string methodName | operation.getFunc().(Attribute).getName() = methodName |
    (methodName = "encode" and
     exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (methodName = "decode" and
     exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Identifies handlers targeting specific exception types with minimal handling
predicate isMinimalExceptionHandler(ExceptStmt handler, Stmt statement, Expr exceptionType) {
  // Single-statement try block with specific exception type
  not exists(handler.getTry().getStmt(1)) and
  statement = handler.getTry().getStmt(0) and
  handler.getType() = exceptionType
}

// Detects focused exception handlers for specific error scenarios
predicate isFocusedHandler(ExceptStmt handler) {
  // Check for targeted exception handling patterns
  exists(Stmt statement, Expr exceptionType | isMinimalExceptionHandler(handler, statement, exceptionType) |
    // IndexError for subscript operations
    (involvesSubscriptOperation(statement) and
     exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError for attribute access
    (involvesAttributeAccess(statement) and
     exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError for name references
    (statement.(ExprStmt).getValue() instanceof Name and
     exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding errors
    isEncodeOrDecodeCall(statement.(ExprStmt).getValue(), exceptionType)
  )
}

// Identifies try blocks that contain return statements
predicate tryReturn(Try tryBlock) {
  exists(Return returnStmt | returnStmt.getParentNode*() = tryBlock)
}

// Main query for detecting problematic empty except blocks
from ExceptStmt handler
where
  // Identify empty except blocks without explanations
  isEmptyExcept(handler) and
  lacksElseClause(handler) and
  hasNoComment(handler) and
  // Exclude non-local control flow handlers
  not handlesNonLocalControlFlow(handler) and
  // Exclude try-return constructs
  not tryReturn(handler.getTry()) and
  // Verify normal execution paths exist
  hasNormalExitPath(handler.getTry()) and
  // Exclude focused exception handlers
  not isFocusedHandler(handler)
select handler, "'except' clause does nothing but pass and there is no explanatory comment."