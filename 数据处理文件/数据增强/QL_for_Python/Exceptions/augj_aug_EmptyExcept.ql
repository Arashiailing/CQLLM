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

/**
 * Determines if an except block contains only pass statements.
 * An except block is considered empty if it contains no statements other than pass.
 */
predicate isExceptBlockEmpty(ExceptStmt exceptHandler) {
  // Check that all statements in the except block are pass statements
  forall(Stmt stmt | stmt = exceptHandler.getAStmt() | stmt instanceof Pass)
}

/**
 * Checks if a try statement lacks an else clause.
 * This is relevant because else clauses can provide alternative execution paths.
 */
predicate isElseClauseAbsent(ExceptStmt exceptHandler) { 
  // Verify that the try statement does not have an associated else block
  not exists(exceptHandler.getTry().getOrelse()) 
}

/**
 * Identifies except blocks that do not have associated comments.
 * Comments are important for explaining why an exception is being silently ignored.
 */
predicate lacksExplanatoryComment(ExceptStmt exceptHandler) {
  // Ensure no comments exist within the range of the except block
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptHandler.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptHandler.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptHandler.getBody().getLastItem().getLocation().getEndLine()
  )
}

/**
 * Detects except handlers for non-local control flow exceptions.
 * These exceptions are often used intentionally for control flow and may not require detailed handling.
 */
predicate handlesControlFlowException(ExceptStmt exceptHandler) {
  // Check if the exception type is StopIteration, commonly used for iterator termination
  exceptHandler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

/**
 * Verifies if a try block has normal execution paths that exit the block.
 * This helps distinguish between intentional and unintentional empty except blocks.
 */
predicate hasNormalControlFlowExit(Try tryBlock) {
  // Look for control flow edges that represent non-exceptional transitions
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    // Valid non-exceptional edge exists
    predecessor.getASuccessor() = successor and
    not predecessor.getAnExceptionalSuccessor() = successor
  |
    // Successor is not a return node
    not exists(Scope scope | scope.getReturnNode() = successor) and
    // Predecessor is in try block, successor is outside
    predecessor.getNode().getParentNode*() = tryBlock.getAStmt() and
    not successor.getNode().getParentNode*() = tryBlock.getAStmt()
  )
}

/**
 * Checks if a statement involves attribute access operations.
 * This helps identify focused exception handlers for attribute-related errors.
 */
predicate containsAttributeAccess(Stmt stmt) {
  // Direct attribute access in expression statements
  stmt.(ExprStmt).getValue() instanceof Attribute
  or
  // Attribute access via built-in functions
  exists(string funcName | stmt.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = funcName |
    funcName in ["getattr", "setattr", "delattr"]
  )
  or
  // Attribute deletion operations
  stmt.(Delete).getATarget() instanceof Attribute
}

/**
 * Identifies subscript operations in statements.
 * This helps detect focused exception handlers for indexing-related errors.
 */
predicate containsSubscriptOperation(Stmt stmt) {
  // Subscript access in expression statements
  stmt.(ExprStmt).getValue() instanceof Subscript
  or
  // Subscript deletion operations
  stmt.(Delete).getATarget() instanceof Subscript
}

/**
 * Detects encoding/decoding operations with specific exception types.
 * This helps identify focused exception handlers for encoding/decoding errors.
 */
predicate isEncodingDecodingOperation(Call funcCall, Expr exceptionType) {
  // Verify function name and match corresponding exception type
  exists(string methodName | funcCall.getFunc().(Attribute).getName() = methodName |
    (methodName = "encode" and
     exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (methodName = "decode" and
     exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

/**
 * Identifies handlers targeting specific exception types with minimal handling.
 * These handlers typically have a single statement in the try block.
 */
predicate isMinimalExceptionHandling(ExceptStmt exceptHandler, Stmt tryStmt, Expr exceptionType) {
  // Single-statement try block with specific exception type
  not exists(exceptHandler.getTry().getStmt(1)) and
  tryStmt = exceptHandler.getTry().getStmt(0) and
  exceptHandler.getType() = exceptionType
}

/**
 * Detects focused exception handlers for specific error scenarios.
 * These handlers are typically intentional and should not be flagged as problematic.
 */
predicate isFocusedExceptionHandler(ExceptStmt exceptHandler) {
  // Check for targeted exception handling patterns
  exists(Stmt tryStmt, Expr exceptionType | isMinimalExceptionHandling(exceptHandler, tryStmt, exceptionType) |
    // IndexError for subscript operations
    (containsSubscriptOperation(tryStmt) and
     exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError for attribute access
    (containsAttributeAccess(tryStmt) and
     exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError for name references
    (tryStmt.(ExprStmt).getValue() instanceof Name and
     exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding errors
    isEncodingDecodingOperation(tryStmt.(ExprStmt).getValue(), exceptionType)
  )
}

/**
 * Identifies try blocks that contain return statements.
 * These constructs often use empty except blocks for cleanup purposes.
 */
predicate containsReturnStatement(Try tryBlock) {
  exists(Return returnStmt | returnStmt.getParentNode*() = tryBlock)
}

// Main query for detecting problematic empty except blocks
from ExceptStmt exceptHandler
where
  // Identify empty except blocks without explanations
  isExceptBlockEmpty(exceptHandler) and
  isElseClauseAbsent(exceptHandler) and
  lacksExplanatoryComment(exceptHandler) and
  // Exclude non-local control flow handlers
  not handlesControlFlowException(exceptHandler) and
  // Exclude try-return constructs
  not containsReturnStatement(exceptHandler.getTry()) and
  // Verify normal execution paths exist
  hasNormalControlFlowExit(exceptHandler.getTry()) and
  // Exclude focused exception handlers
  not isFocusedExceptionHandler(exceptHandler)
select exceptHandler, "'except' clause does nothing but pass and there is no explanatory comment."