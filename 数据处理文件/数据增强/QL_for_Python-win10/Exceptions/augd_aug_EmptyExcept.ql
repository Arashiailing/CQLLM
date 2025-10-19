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

// Core exception block analysis predicates
// Determines if an except block contains only pass statements
predicate isEmptyExcept(ExceptStmt exceptBlock) {
  // Verify absence of non-pass statements in the except block
  not exists(Stmt statement | statement = exceptBlock.getAStmt() and not statement instanceof Pass)
}

// Checks if an except statement lacks an else clause
predicate lacksElseClause(ExceptStmt exceptBlock) { 
  // Confirm the absence of an else block in the try statement
  not exists(exceptBlock.getTry().getOrelse()) 
}

// Identifies except blocks without associated comments
predicate hasNoComment(ExceptStmt exceptBlock) {
  // Verify no comments exist within the except block's range
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptBlock.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptBlock.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptBlock.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Special exception handling cases
// Detects except handlers for non-local control flow exceptions
predicate handlesNonLocalControlFlow(ExceptStmt exceptBlock) {
  // Check if the exception type is StopIteration
  exceptBlock.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Identifies try blocks that contain return statements
predicate tryReturn(Try tryStatement) {
  exists(Return returnStatement | returnStatement.getParentNode*() = tryStatement)
}

// Control flow and execution path analysis
// Verifies if a try block has normal execution paths
predicate hasNormalExitPath(Try tryStatement) {
  // Look for non-exceptional control flow transitions
  exists(ControlFlowNode predecessorNode, ControlFlowNode successorNode |
    /* Valid non-exceptional edge exists */
    predecessorNode.getASuccessor() = successorNode and
    not predecessorNode.getAnExceptionalSuccessor() = successorNode
  |
    /* Successor isn't a return node */
    not exists(Scope scope | scope.getReturnNode() = successorNode) and
    /* Predecessor is in try block, successor is outside */
    predecessorNode.getNode().getParentNode*() = tryStatement.getAStmt() and
    not successorNode.getNode().getParentNode*() = tryStatement.getAStmt()
  )
}

// Statement pattern detection predicates
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

// Encoding/decoding operation analysis
// Detects encoding/decoding operations with specific exception types
predicate isEncodeOrDecodeCall(Call methodCall, Expr exceptionType) {
  // Verify function name and match corresponding exception type
  exists(string methodName | methodCall.getFunc().(Attribute).getName() = methodName |
    (methodName = "encode" and
     exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (methodName = "decode" and
     exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Exception handler specificity analysis
// Identifies handlers targeting specific exception types with minimal handling
predicate isMinimalExceptionHandler(ExceptStmt exceptBlock, Stmt statement, Expr exceptionType) {
  // Single-statement try block with specific exception type
  not exists(exceptBlock.getTry().getStmt(1)) and
  statement = exceptBlock.getTry().getStmt(0) and
  exceptBlock.getType() = exceptionType
}

// Detects focused exception handlers for specific error scenarios
predicate isFocusedHandler(ExceptStmt exceptBlock) {
  // Check for targeted exception handling patterns
  exists(Stmt statement, Expr exceptionType | isMinimalExceptionHandler(exceptBlock, statement, exceptionType) |
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

// Main query for detecting problematic empty except blocks
from ExceptStmt exceptBlock
where
  // Identify empty except blocks without explanations
  isEmptyExcept(exceptBlock) and
  lacksElseClause(exceptBlock) and
  hasNoComment(exceptBlock) and
  // Exclude non-local control flow handlers
  not handlesNonLocalControlFlow(exceptBlock) and
  // Exclude try-return constructs
  not tryReturn(exceptBlock.getTry()) and
  // Verify normal execution paths exist
  hasNormalExitPath(exceptBlock.getTry()) and
  // Exclude focused exception handlers
  not isFocusedHandler(exceptBlock)
select exceptBlock, "'except' clause does nothing but pass and there is no explanatory comment."