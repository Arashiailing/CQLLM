/**
 * @name Empty except
 * @description Identifies except blocks containing only pass statements without explanatory comments
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/empty-except
 */

import python
import semmle.python.ApiGraphs

/**
 * Determines if an except clause contains only pass statements.
 * @param exceptClause The except clause to check.
 */
predicate isExceptBlockEmpty(ExceptStmt exceptClause) {
  // Verify all statements within except block are pass statements
  not exists(Stmt statement | 
    statement = exceptClause.getAStmt() and 
    not statement instanceof Pass
  )
}

/**
 * Checks if a try-except construct lacks an else clause.
 * @param exceptClause The except clause to check.
 */
predicate lacksElseClause(ExceptStmt exceptClause) { 
  // Confirm try statement lacks else block
  not exists(exceptClause.getTry().getOrelse()) 
}

/**
 * Verifies absence of explanatory comments within except clauses.
 * @param exceptClause The except clause to check.
 */
predicate hasNoExplanatoryComment(ExceptStmt exceptClause) {
  // Ensure no comments exist within except block boundaries
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptClause.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptClause.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptClause.getBody().getLastItem().getLocation().getEndLine()
  )
}

/**
 * Identifies handlers for non-local control flow exceptions.
 * @param exceptClause The except clause to check.
 */
predicate handlesControlFlowException(ExceptStmt exceptClause) {
  // Check for StopIteration exception handling
  exceptClause.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

/**
 * Verifies normal execution exits from try block.
 * @param tryStmt The try statement to check.
 */
predicate hasNormalExitPath(Try tryStmt) {
  // Find non-exceptional control flow transitions
  exists(ControlFlowNode prevNode, ControlFlowNode nextNode |
    /* Normal (non-exceptional) control flow edge */
    prevNode.getASuccessor() = nextNode and
    not prevNode.getAnExceptionalSuccessor() = nextNode
  |
    /* Valid successor: not a return node */
    not exists(Scope scope | scope.getReturnNode() = nextNode) and
    /* Predecessor in try body, successor outside */
    prevNode.getNode().getParentNode*() = tryStmt.getAStmt() and
    not nextNode.getNode().getParentNode*() = tryStmt.getAStmt()
  )
}

/**
 * Detects attribute access operations in statements.
 * @param statement The statement to check.
 */
predicate containsAttributeAccess(Stmt statement) {
  // Direct attribute access or getattr/setattr/delattr calls
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string methodName | 
    statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = methodName |
    methodName = "getattr" or methodName = "setattr" or methodName = "delattr"
  )
  or
  statement.(Delete).getATarget() instanceof Attribute
}

/**
 * Detects subscript operations in statements.
 * @param statement The statement to check.
 */
predicate containsSubscriptOperation(Stmt statement) {
  // Subscript access or deletion
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  statement.(Delete).getATarget() instanceof Subscript
}

/**
 * Identifies encode/decode operations with corresponding exception types.
 * @param methodCall The method call expression to check.
 * @param handledException The exception type being handled.
 */
predicate isCodecOperation(Call methodCall, Expr handledException) {
  // Match encode/decode calls with corresponding exception types
  exists(string opName | 
    methodCall.getFunc().(Attribute).getName() = opName |
    opName = "encode" and
    handledException = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    opName = "decode" and
    handledException = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

/**
 * Identifies single-statement exception handlers.
 * @param exceptClause The except clause to check.
 * @param statement The single statement in the try block.
 * @param handledException The exception type being handled.
 */
predicate isSingleStatementHandler(ExceptStmt exceptClause, Stmt statement, Expr handledException) {
  // Verify try block contains exactly one statement
  not exists(exceptClause.getTry().getStmt(1)) and
  statement = exceptClause.getTry().getStmt(0) and
  exceptClause.getType() = handledException
}

/**
 * Detects focused exception handlers for specific operations.
 * @param exceptClause The except clause to check.
 */
predicate isSpecializedHandler(ExceptStmt exceptClause) {
  // Check for specific exception handling patterns
  exists(Stmt statement, Expr handledException | 
    isSingleStatementHandler(exceptClause, statement, handledException) |
    // Subscript operations with IndexError
    containsSubscriptOperation(statement) and
    handledException = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    containsAttributeAccess(statement) and
    handledException = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    statement.(ExprStmt).getValue() instanceof Name and
    handledException = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    isCodecOperation(statement.(ExprStmt).getValue(), handledException)
  )
}

// Main query to identify problematic empty except blocks
from ExceptStmt exceptClause
where
  // Core conditions: empty except block without else clause or comments
  isExceptBlockEmpty(exceptClause) and
  lacksElseClause(exceptClause) and
  hasNoExplanatoryComment(exceptClause) and
  // Exclude non-local control flow handlers
  not handlesControlFlowException(exceptClause) and
  // Ensure try block has normal execution path
  hasNormalExitPath(exceptClause.getTry()) and
  // Exclude specialized exception handlers
  not isSpecializedHandler(exceptClause)
select exceptClause, "'except' clause does nothing but pass and there is no explanatory comment."