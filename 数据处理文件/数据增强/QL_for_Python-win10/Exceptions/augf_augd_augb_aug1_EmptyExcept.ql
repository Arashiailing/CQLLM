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
 * Evaluates whether an except clause solely consists of pass statements.
 * @param targetExcept The except clause under evaluation.
 */
predicate containsOnlyPassStatements(ExceptStmt targetExcept) {
  // Validate that every statement within the except block is a pass statement
  not exists(Stmt currentStmt | 
    currentStmt = targetExcept.getAStmt() and 
    not currentStmt instanceof Pass
  )
}

/**
 * Determines if a try-except structure omits an else clause.
 * @param targetExcept The except clause to examine.
 */
predicate isMissingElseClause(ExceptStmt targetExcept) { 
  // Verify that the try statement does not have an associated else block
  not exists(targetExcept.getTry().getOrelse()) 
}

/**
 * Confirms the absence of explanatory comments within except clauses.
 * @param targetExcept The except clause to inspect.
 */
predicate lacksExplanatoryComments(ExceptStmt targetExcept) {
  // Ensure no comments are present within the except block's boundaries
  not exists(Comment foundComment |
    foundComment.getLocation().getFile() = targetExcept.getLocation().getFile() and
    foundComment.getLocation().getStartLine() >= targetExcept.getLocation().getStartLine() and
    foundComment.getLocation().getEndLine() <= targetExcept.getBody().getLastItem().getLocation().getEndLine()
  )
}

/**
 * Identifies exception handlers that manage non-local control flow exceptions.
 * @param targetExcept The except clause to analyze.
 */
predicate managesControlFlowExceptions(ExceptStmt targetExcept) {
  // Detect handling of StopIteration exception
  targetExcept.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

/**
 * Verifies that normal execution paths exist from the try block.
 * @param targetTry The try statement to evaluate.
 */
predicate hasNormalExecutionExit(Try targetTry) {
  // Identify non-exceptional control flow transitions
  exists(ControlFlowNode predecessorNode, ControlFlowNode successorNode |
    /* Standard (non-exceptional) control flow connection */
    predecessorNode.getASuccessor() = successorNode and
    not predecessorNode.getAnExceptionalSuccessor() = successorNode
  |
    /* Valid successor: not a return node */
    not exists(Scope currentScope | currentScope.getReturnNode() = successorNode) and
    /* Predecessor within try body, successor outside */
    predecessorNode.getNode().getParentNode*() = targetTry.getAStmt() and
    not successorNode.getNode().getParentNode*() = targetTry.getAStmt()
  )
}

/**
 * Detects attribute access operations within statements.
 * @param targetStmt The statement to examine.
 */
predicate includesAttributeAccess(Stmt targetStmt) {
  // Direct attribute access or getattr/setattr/delattr function calls
  targetStmt.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string functionName | 
    targetStmt.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = functionName |
    functionName = "getattr" or functionName = "setattr" or functionName = "delattr"
  )
  or
  targetStmt.(Delete).getATarget() instanceof Attribute
}

/**
 * Identifies subscript operations within statements.
 * @param targetStmt The statement to analyze.
 */
predicate includesSubscriptOperation(Stmt targetStmt) {
  // Subscript access or deletion operations
  targetStmt.(ExprStmt).getValue() instanceof Subscript
  or
  targetStmt.(Delete).getATarget() instanceof Subscript
}

/**
 * Matches encode/decode operations with their corresponding exception types.
 * @param methodInvocation The method call expression to check.
 * @param exceptionType The exception type being handled.
 */
predicate isEncodingDecodingOperation(Call methodInvocation, Expr exceptionType) {
  // Correlate encode/decode calls with their respective exception types
  exists(string operationName | 
    methodInvocation.getFunc().(Attribute).getName() = operationName |
    operationName = "encode" and
    exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    operationName = "decode" and
    exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

/**
 * Identifies exception handlers that manage only a single statement.
 * @param targetExcept The except clause to evaluate.
 * @param singleStatement The solitary statement in the try block.
 * @param handledException The exception type being managed.
 */
predicate isSingleStatementExceptionHandler(ExceptStmt targetExcept, Stmt singleStatement, Expr handledException) {
  // Confirm the try block contains precisely one statement
  not exists(targetExcept.getTry().getStmt(1)) and
  singleStatement = targetExcept.getTry().getStmt(0) and
  targetExcept.getType() = handledException
}

/**
 * Detects specialized exception handlers targeting specific operations.
 * @param targetExcept The except clause to analyze.
 */
predicate isFocusedExceptionHandler(ExceptStmt targetExcept) {
  // Identify specific exception handling patterns
  exists(Stmt operationStatement, Expr caughtException | 
    isSingleStatementExceptionHandler(targetExcept, operationStatement, caughtException) |
    // Subscript operations with IndexError
    includesSubscriptOperation(operationStatement) and
    caughtException = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    includesAttributeAccess(operationStatement) and
    caughtException = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    operationStatement.(ExprStmt).getValue() instanceof Name and
    caughtException = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    isEncodingDecodingOperation(operationStatement.(ExprStmt).getValue(), caughtException)
  )
}

// Primary query to identify problematic empty except blocks
from ExceptStmt targetExcept
where
  // Fundamental criteria: empty except block without else clause or explanatory comments
  containsOnlyPassStatements(targetExcept) and
  isMissingElseClause(targetExcept) and
  lacksExplanatoryComments(targetExcept) and
  // Exclude handlers for non-local control flow exceptions
  not managesControlFlowExceptions(targetExcept) and
  // Ensure the try block has a normal execution path
  hasNormalExecutionExit(targetExcept.getTry()) and
  // Exclude specialized exception handlers
  not isFocusedExceptionHandler(targetExcept)
select targetExcept, "'except' clause does nothing but pass and there is no explanatory comment."