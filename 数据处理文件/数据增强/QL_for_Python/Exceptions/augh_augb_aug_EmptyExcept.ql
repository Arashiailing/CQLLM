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

// Statement content analysis predicates
predicate containsOnlyPassStatements(ExceptStmt exceptHandler) {
  // Verify that the except block exclusively consists of pass statements
  not exists(Stmt currentStmt | 
    currentStmt = exceptHandler.getAStmt() and 
    not currentStmt instanceof Pass
  )
}

predicate lacksElseBranch(ExceptStmt exceptHandler) { 
  // Confirm that the associated try statement does not have an else clause
  not exists(exceptHandler.getTry().getOrelse()) 
}

// Comment presence verification
predicate lacksExplanatoryComment(ExceptStmt exceptHandler) {
  // Determine if there are no comments within the except block's scope
  not exists(Comment existingComment |
    existingComment.getLocation().getFile() = exceptHandler.getLocation().getFile() and
    existingComment.getLocation().getStartLine() >= exceptHandler.getLocation().getStartLine() and
    existingComment.getLocation().getEndLine() <= exceptHandler.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Exception type classification predicates
predicate handlesControlFlowException(ExceptStmt exceptHandler) {
  // Identify handlers that catch StopIteration exceptions (used for control flow)
  exceptHandler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Control flow path analysis
predicate hasNonExceptionalExit(Try tryBlock) {
  // Check for normal (non-exceptional) execution paths exiting the try block
  exists(ControlFlowNode predecessorNode, ControlFlowNode successorNode |
    /* Normal control flow edge exists */
    predecessorNode.getASuccessor() = successorNode and
    not predecessorNode.getAnExceptionalSuccessor() = successorNode
  |
    /* Successor is not a return statement */
    not exists(Scope currentScope | currentScope.getReturnNode() = successorNode) and
    /* Predecessor is inside try block, successor is outside */
    predecessorNode.getNode().getParentNode*() = tryBlock.getAStmt() and
    not successorNode.getNode().getParentNode*() = tryBlock.getAStmt()
  )
}

// Statement pattern detection predicates
predicate usesAttributeAccess(Stmt targetStatement) {
  // Detect attribute access in expression statements
  targetStatement.(ExprStmt).getValue() instanceof Attribute
  or
  // Detect attribute operations via built-in functions
  exists(string functionName | 
    targetStatement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = functionName |
    functionName in ["getattr", "setattr", "delattr"]
  )
  or
  // Detect attribute deletion
  targetStatement.(Delete).getATarget() instanceof Attribute
}

predicate usesSubscriptOperation(Stmt targetStatement) {
  // Detect subscript access in expressions
  targetStatement.(ExprStmt).getValue() instanceof Subscript
  or
  // Detect subscript deletion
  targetStatement.(Delete).getATarget() instanceof Subscript
}

// Encoding/decoding operation analysis
predicate handlesEncodingDecoding(Call functionCall, Expr exceptionType) {
  // Match encoding/decoding operations with their corresponding exception types
  exists(string operationName | functionCall.getFunc().(Attribute).getName() = operationName |
    (operationName = "encode" and
     exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (operationName = "decode" and
     exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Minimal exception handler identification
predicate isMinimalHandler(ExceptStmt exceptHandler, Stmt protectedStatement, Expr caughtException) {
  // Identify single-statement try blocks with specific exception handling
  not exists(exceptHandler.getTry().getStmt(1)) and
  protectedStatement = exceptHandler.getTry().getStmt(0) and
  exceptHandler.getType() = caughtException
}

// Targeted exception handler detection
predicate isTargetedExceptionHandler(ExceptStmt exceptHandler) {
  // Detect handlers specifically designed for particular error scenarios
  exists(Stmt protectedCode, Expr handledException | 
    isMinimalHandler(exceptHandler, protectedCode, handledException) |
    // IndexError handling for subscript operations
    (usesSubscriptOperation(protectedCode) and
     handledException = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // AttributeError handling for attribute access
    (usesAttributeAccess(protectedCode) and
     handledException = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // NameError handling for name references
    (protectedCode.(ExprStmt).getValue() instanceof Name and
     handledException = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding error handling
    handlesEncodingDecoding(protectedCode.(ExprStmt).getValue(), handledException)
  )
}

// Try block content analysis
predicate containsReturnStatement(Try tryBlock) {
  exists(Return returnStatement | returnStatement.getParentNode*() = tryBlock)
}

// Main query for identifying problematic empty except blocks
from ExceptStmt problematicExcept
where
  // Core conditions: empty except block without explanation
  containsOnlyPassStatements(problematicExcept) and
  lacksElseBranch(problematicExcept) and
  lacksExplanatoryComment(problematicExcept) and
  // Exclude legitimate use cases
  not handlesControlFlowException(problematicExcept) and
  not containsReturnStatement(problematicExcept.getTry()) and
  // Verify normal execution flow
  hasNonExceptionalExit(problematicExcept.getTry()) and
  // Exclude purpose-built exception handlers
  not isTargetedExceptionHandler(problematicExcept)
select problematicExcept, "'except' clause does nothing but pass and there is no explanatory comment."