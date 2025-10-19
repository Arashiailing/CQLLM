/**
 * @name Empty except
 * @description Identifies except clauses that contain only pass statements without explanatory comments
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

// Determines if an except block exclusively contains pass statements
predicate isEmptyExcept(ExceptStmt exceptBlock) {
  // Confirm absence of non-pass statements in the exception handler
  not exists(Stmt stmt | 
    stmt = exceptBlock.getAStmt() and 
    not stmt instanceof Pass
  )
}

// Verifies absence of else clause in try statement
predicate lacksElseClause(ExceptStmt exceptBlock) { 
  // Ensure no else block exists in the try statement
  not exists(exceptBlock.getTry().getOrelse()) 
}

// Detects exception handlers without associated comments
predicate hasNoComment(ExceptStmt exceptBlock) {
  // Check for absence of comments within the except block's scope
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptBlock.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptBlock.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptBlock.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Identifies handlers for non-local control flow exceptions
predicate handlesNonLocalControlFlow(ExceptStmt exceptBlock) {
  // Check if StopIteration exception is being handled
  exceptBlock.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Verifies normal execution paths exist in try blocks
predicate hasNormalExitPath(Try tryStmt) {
  // Identify non-exceptional control flow transitions
  exists(ControlFlowNode predNode, ControlFlowNode succNode |
    /* Valid non-exceptional edge exists */
    predNode.getASuccessor() = succNode and
    not predNode.getAnExceptionalSuccessor() = succNode
  |
    /* Successor is not a return node */
    not exists(Scope s | s.getReturnNode() = succNode) and
    /* Predecessor in try block, successor outside */
    predNode.getNode().getParentNode*() = tryStmt.getAStmt() and
    not succNode.getNode().getParentNode*() = tryStmt.getAStmt()
  )
}

// Detects statements involving attribute access
predicate involvesAttributeAccess(Stmt stmt) {
  // Attribute access in expression statements
  stmt.(ExprStmt).getValue() instanceof Attribute
  or
  // Attribute access via built-in functions
  exists(string name | 
    stmt.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = name |
    name in ["getattr", "setattr", "delattr"]
  )
  or
  // Attribute deletion operations
  stmt.(Delete).getATarget() instanceof Attribute
}

// Identifies statements with subscript operations
predicate involvesSubscriptOperation(Stmt stmt) {
  // Subscript access in expressions
  stmt.(ExprStmt).getValue() instanceof Subscript
  or
  // Subscript deletion operations
  stmt.(Delete).getATarget() instanceof Subscript
}

// Detects encoding/decoding operations with specific exceptions
predicate isEncodeOrDecodeCall(Call callNode, Expr exceptTypeExpr) {
  // Verify function name and match corresponding exception type
  exists(string methodName | 
    callNode.getFunc().(Attribute).getName() = methodName |
    (methodName = "encode" and
     exceptTypeExpr = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (methodName = "decode" and
     exceptTypeExpr = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Identifies minimal exception handlers for specific types
predicate isMinimalExceptionHandler(ExceptStmt exceptBlock, Stmt stmt, Expr exceptTypeExpr) {
  // Single-statement try block with specific exception type
  not exists(exceptBlock.getTry().getStmt(1)) and
  stmt = exceptBlock.getTry().getStmt(0) and
  exceptBlock.getType() = exceptTypeExpr
}

// Detects focused exception handlers for specific scenarios
predicate isFocusedHandler(ExceptStmt exceptBlock) {
  // Check for targeted exception handling patterns
  exists(Stmt stmt, Expr exceptTypeExpr | 
    isMinimalExceptionHandler(exceptBlock, stmt, exceptTypeExpr) |
    // IndexError for subscript operations
    (involvesSubscriptOperation(stmt) and
     exceptTypeExpr = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError for attribute access
    (involvesAttributeAccess(stmt) and
     exceptTypeExpr = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError for name references
    (stmt.(ExprStmt).getValue() instanceof Name and
     exceptTypeExpr = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding errors
    isEncodeOrDecodeCall(stmt.(ExprStmt).getValue(), exceptTypeExpr)
  )
}

// Identifies try blocks containing return statements
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