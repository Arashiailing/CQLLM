/**
 * @name Empty except
 * @description Identifies except clauses that contain only pass statements without explanatory comments
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

// Predicate to determine if except block contains exclusively pass statements
predicate containsOnlyPassStatements(ExceptStmt exceptClause) {
  // Confirm all statements within the except block are pass statements
  forall(Stmt statement | statement = exceptClause.getAStmt() | statement instanceof Pass)
}

// Predicate to verify absence of else clause in try-except construct
predicate lacksElseClause(ExceptStmt exceptClause) { 
  // Ensure the try statement does not have an associated else block
  not exists(exceptClause.getTry().getOrelse()) 
}

// Predicate to check for missing explanatory comments within except block
predicate hasNoExplanatoryComment(ExceptStmt exceptClause) {
  // Verify no comments exist within the except block's code boundaries
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptClause.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptClause.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptClause.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Predicate to identify handlers for non-local control flow exceptions
predicate handlesNonLocalFlowException(ExceptStmt exceptClause) {
  // Check if the except clause handles StopIteration exceptions
  exceptClause.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Predicate to verify normal execution exits from try block
predicate hasNormalExitPath(Try tryStatement) {
  // Find non-exceptional control flow transitions exiting the try block
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    /* Normal (non-exceptional) control flow edge */
    predecessor.getASuccessor() = successor and
    not predecessor.getAnExceptionalSuccessor() = successor
  |
    /* Valid successor: not a return node */
    not exists(Scope scope | scope.getReturnNode() = successor) and
    /* Predecessor in try body, successor outside */
    predecessor.getNode().getParentNode*() = tryStatement.getAStmt() and
    not successor.getNode().getParentNode*() = tryStatement.getAStmt()
  )
}

// Predicate to detect attribute access operations in statements
predicate involvesAttributeAccess(Stmt codeStatement) {
  // Direct attribute access or getattr/setattr/delattr function calls
  codeStatement.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string functionName | 
    codeStatement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = functionName |
    functionName = "getattr" or functionName = "setattr" or functionName = "delattr"
  )
  or
  codeStatement.(Delete).getATarget() instanceof Attribute
}

// Predicate to detect subscript operations in statements
predicate involvesSubscriptOperation(Stmt codeStatement) {
  // Subscript access or deletion operations
  codeStatement.(ExprStmt).getValue() instanceof Subscript
  or
  codeStatement.(Delete).getATarget() instanceof Subscript
}

// Predicate to identify encode/decode operations with corresponding exceptions
predicate isEncodingDecodingCall(Call functionCall, Expr exceptionType) {
  // Match encode/decode method calls with corresponding exception types
  exists(string methodName | 
    functionCall.getFunc().(Attribute).getName() = methodName |
    (methodName = "encode" and
     exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr())
    or
    (methodName = "decode" and
     exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr())
  )
}

// Predicate to identify single-statement exception handlers
predicate isSingleStatementHandler(ExceptStmt exceptClause, Stmt handledStatement, Expr caughtException) {
  // Verify the try block contains exactly one statement
  not exists(exceptClause.getTry().getStmt(1)) and
  handledStatement = exceptClause.getTry().getStmt(0) and
  exceptClause.getType() = caughtException
}

// Predicate to detect focused exception handlers for specific operations
predicate isFocusedExceptionHandler(ExceptStmt exceptClause) {
  // Check for specific exception handling patterns tied to particular operations
  exists(Stmt operationStatement, Expr exceptionType | 
    isSingleStatementHandler(exceptClause, operationStatement, exceptionType) |
    // Subscript operations with IndexError
    (involvesSubscriptOperation(operationStatement) and
     exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr())
    or
    // Attribute access with AttributeError
    (involvesAttributeAccess(operationStatement) and
     exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr())
    or
    // Name access with NameError
    (operationStatement.(ExprStmt).getValue() instanceof Name and
     exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr())
    or
    // Encoding/decoding operations with corresponding exceptions
    isEncodingDecodingCall(operationStatement.(ExprStmt).getValue(), exceptionType)
  )
}

// Main query to identify problematic empty except blocks
from ExceptStmt exceptClause
where
  // Core conditions: empty except block without else clause or explanatory comments
  containsOnlyPassStatements(exceptClause) and
  lacksElseClause(exceptClause) and
  hasNoExplanatoryComment(exceptClause) and
  // Exclude handlers for non-local control flow exceptions
  not handlesNonLocalFlowException(exceptClause) and
  // Ensure the try block has a normal execution exit path
  hasNormalExitPath(exceptClause.getTry()) and
  // Exclude focused exception handlers for specific operations
  not isFocusedExceptionHandler(exceptClause)
select exceptClause, "'except' clause does nothing but pass and there is no explanatory comment."