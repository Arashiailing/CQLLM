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
predicate isExceptBlockEmpty(ExceptStmt excBlock) {
  // Check that the except block contains no non-pass statements
  not exists(Stmt stmt | stmt = excBlock.getAStmt() and not stmt instanceof Pass)
}

// Checks if an except statement lacks an else clause
predicate isElseClauseAbsent(ExceptStmt excBlock) { 
  // Ensure that the try statement does not have an associated else block
  not exists(excBlock.getTry().getOrelse()) 
}

// Identifies except blocks without associated comments
predicate isCommentAbsent(ExceptStmt excBlock) {
  // Confirm that no comments exist within the except block's scope
  not exists(Comment cmt |
    cmt.getLocation().getFile() = excBlock.getLocation().getFile() and
    cmt.getLocation().getStartLine() >= excBlock.getLocation().getStartLine() and
    cmt.getLocation().getEndLine() <= excBlock.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Detects except handlers for non-local control flow exceptions
predicate handlesControlFlowException(ExceptStmt excBlock) {
  // Verify if the exception type is StopIteration
  excBlock.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Verifies if a try block has normal execution paths
predicate hasNormalExecutionPath(Try tryStmt) {
  // Search for non-exceptional control flow transitions
  exists(ControlFlowNode pred, ControlFlowNode succ |
    /* Non-exceptional edge exists between nodes */
    pred.getASuccessor() = succ and
    not pred.getAnExceptionalSuccessor() = succ
  |
    /* Successor is not a return node */
    not exists(Scope scope | scope.getReturnNode() = succ) and
    /* Predecessor is in try block, successor is outside */
    pred.getNode().getParentNode*() = tryStmt.getAStmt() and
    not succ.getNode().getParentNode*() = tryStmt.getAStmt()
  )
}

// Checks if a statement involves attribute access
predicate containsAttributeAccess(Stmt stmt) {
  // Attribute access in expression statements
  stmt.(ExprStmt).getValue() instanceof Attribute
  or
  // Attribute access via built-in functions
  exists(string funcName | stmt.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = funcName |
    funcName in ["getattr", "setattr", "delattr"]
  )
  or
  // Attribute deletion
  stmt.(Delete).getATarget() instanceof Attribute
}

// Identifies subscript operations in statements
predicate containsSubscriptOperation(Stmt stmt) {
  // Subscript access in expressions
  stmt.(ExprStmt).getValue() instanceof Subscript
  or
  // Subscript deletion
  stmt.(Delete).getATarget() instanceof Subscript
}

// Detects encoding/decoding operations with specific exception types
predicate isEncodingDecodingCall(Call funcCall, Expr excType) {
  // Verify function name and match corresponding exception type
  exists(string opName | funcCall.getFunc().(Attribute).getName() = opName |
    (opName = "encode" and
     excType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (opName = "decode" and
     excType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Identifies handlers targeting specific exception types with minimal handling
predicate isTargetedExceptionHandler(ExceptStmt excBlock, Stmt stmt, Expr excType) {
  // Single-statement try block with specific exception type
  not exists(excBlock.getTry().getStmt(1)) and
  stmt = excBlock.getTry().getStmt(0) and
  excBlock.getType() = excType
}

// Detects focused exception handlers for specific error scenarios
predicate isSpecializedHandler(ExceptStmt excBlock) {
  // Check for targeted exception handling patterns
  exists(Stmt stmt, Expr excType | isTargetedExceptionHandler(excBlock, stmt, excType) |
    // IndexError for subscript operations
    (containsSubscriptOperation(stmt) and
     excType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError for attribute access
    (containsAttributeAccess(stmt) and
     excType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError for name references
    (stmt.(ExprStmt).getValue() instanceof Name and
     excType = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding errors
    isEncodingDecodingCall(stmt.(ExprStmt).getValue(), excType)
  )
}

// Identifies try blocks that contain return statements
predicate containsReturnStatement(Try tryStmt) {
  exists(Return retStmt | retStmt.getParentNode*() = tryStmt)
}

// Main query for detecting problematic empty except blocks
from ExceptStmt excBlock
where
  // Identify empty except blocks without explanations
  isExceptBlockEmpty(excBlock) and
  isElseClauseAbsent(excBlock) and
  isCommentAbsent(excBlock) and
  // Exclude non-local control flow handlers
  not handlesControlFlowException(excBlock) and
  // Exclude try-return constructs
  not containsReturnStatement(excBlock.getTry()) and
  // Verify normal execution paths exist
  hasNormalExecutionPath(excBlock.getTry()) and
  // Exclude focused exception handlers
  not isSpecializedHandler(excBlock)
select excBlock, "'except' clause does nothing but pass and there is no explanatory comment."