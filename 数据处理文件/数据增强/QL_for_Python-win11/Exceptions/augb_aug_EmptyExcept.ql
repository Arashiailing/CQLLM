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
predicate isEmptyExcept(ExceptStmt exceptBlock) {
  // Verify absence of non-pass statements in the except block
  not exists(Stmt stmt | stmt = exceptBlock.getAStmt() and not stmt instanceof Pass)
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

// Detects except handlers for non-local control flow exceptions
predicate handlesNonLocalControlFlow(ExceptStmt exceptBlock) {
  // Check if the exception type is StopIteration
  exceptBlock.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Verifies if a try block has normal execution paths
predicate hasNormalExitPath(Try tryStmt) {
  // Look for non-exceptional control flow transitions
  exists(ControlFlowNode predNode, ControlFlowNode succNode |
    /* Valid non-exceptional edge exists */
    predNode.getASuccessor() = succNode and
    not predNode.getAnExceptionalSuccessor() = succNode
  |
    /* Successor isn't a return node */
    not exists(Scope s | s.getReturnNode() = succNode) and
    /* Predecessor is in try block, successor is outside */
    predNode.getNode().getParentNode*() = tryStmt.getAStmt() and
    not succNode.getNode().getParentNode*() = tryStmt.getAStmt()
  )
}

// Checks if a statement involves attribute access
predicate involvesAttributeAccess(Stmt statement) {
  // Attribute access in expression statements
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  // Attribute access via built-in functions
  exists(string funcName | statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = funcName |
    funcName in ["getattr", "setattr", "delattr"]
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
predicate isEncodeOrDecodeCall(Call methodCall, Expr targetException) {
  // Verify function name and match corresponding exception type
  exists(string methodName | methodCall.getFunc().(Attribute).getName() = methodName |
    (methodName = "encode" and
     targetException = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (methodName = "decode" and
     targetException = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Identifies handlers targeting specific exception types with minimal handling
predicate isMinimalExceptionHandler(ExceptStmt exceptBlock, Stmt statement, Expr targetException) {
  // Single-statement try block with specific exception type
  not exists(exceptBlock.getTry().getStmt(1)) and
  statement = exceptBlock.getTry().getStmt(0) and
  exceptBlock.getType() = targetException
}

// Detects focused exception handlers for specific error scenarios
predicate isFocusedHandler(ExceptStmt exceptBlock) {
  // Check for targeted exception handling patterns
  exists(Stmt statement, Expr targetException | isMinimalExceptionHandler(exceptBlock, statement, targetException) |
    // IndexError for subscript operations
    (involvesSubscriptOperation(statement) and
     targetException = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError for attribute access
    (involvesAttributeAccess(statement) and
     targetException = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError for name references
    (statement.(ExprStmt).getValue() instanceof Name and
     targetException = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding errors
    isEncodeOrDecodeCall(statement.(ExprStmt).getValue(), targetException)
  )
}

// Identifies try blocks that contain return statements
predicate tryReturn(Try tryStmt) {
  exists(Return returnStmt | returnStmt.getParentNode*() = tryStmt)
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