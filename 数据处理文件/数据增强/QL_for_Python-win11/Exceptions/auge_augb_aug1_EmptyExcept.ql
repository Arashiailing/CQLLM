/**
 * @name Empty except
 * @description Detects exception handlers that only contain pass statements without explanatory comments
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

// Determines if an exception handler exclusively consists of pass statements
predicate is_empty_except_block(ExceptStmt exceptionHandler) {
  // Validate that all statements in the exception handler are pass statements
  not exists(Stmt statement | 
    statement = exceptionHandler.getAStmt() and 
    not statement instanceof Pass
  )
}

// Checks whether a try-except construct lacks an else clause
predicate lacks_else_clause(ExceptStmt exceptionHandler) { 
  // Verify that the try statement does not have an associated else block
  not exists(exceptionHandler.getTry().getOrelse()) 
}

// Verifies the absence of explanatory comments within exception handlers
predicate has_no_explanatory_comment(ExceptStmt exceptionHandler) {
  // Confirm that no comments are present within the exception handler's boundaries
  not exists(Comment explanation |
    explanation.getLocation().getFile() = exceptionHandler.getLocation().getFile() and
    explanation.getLocation().getStartLine() >= exceptionHandler.getLocation().getStartLine() and
    explanation.getLocation().getEndLine() <= exceptionHandler.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Identifies exception handlers that manage non-local control flow exceptions
predicate manages_control_flow_exceptions(ExceptStmt exceptionHandler) {
  // Detect handling of StopIteration exceptions
  exceptionHandler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Confirms that normal execution can exit from the try block
predicate has_normal_exit_path(Try tryStatement) {
  // Identify non-exceptional control flow transitions
  exists(ControlFlowNode priorNode, ControlFlowNode nextNode |
    /* Standard (non-exceptional) control flow connection */
    priorNode.getASuccessor() = nextNode and
    not priorNode.getAnExceptionalSuccessor() = nextNode
  |
    /* Valid next node: not a return statement */
    not exists(Scope scope | scope.getReturnNode() = nextNode) and
    /* Prior node in try body, next node outside */
    priorNode.getNode().getParentNode*() = tryStatement.getAStmt() and
    not nextNode.getNode().getParentNode*() = tryStatement.getAStmt()
  )
}

// Detects attribute access operations within statements
predicate involves_attribute_access(Stmt statement) {
  // Direct attribute access or getattr/setattr/delattr invocations
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string methodName | 
    statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = methodName |
    methodName = "getattr" or methodName = "setattr" or methodName = "delattr"
  )
  or
  statement.(Delete).getATarget() instanceof Attribute
}

// Identifies subscript operations within statements
predicate involves_subscript_operation(Stmt statement) {
  // Subscript access or deletion
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  statement.(Delete).getATarget() instanceof Subscript
}

// Matches encode/decode operations with their corresponding exception types
predicate is_codec_related_operation(Call methodCall, Expr caughtException) {
  // Associate encode/decode calls with appropriate exception types
  exists(string operationName | 
    methodCall.getFunc().(Attribute).getName() = operationName |
    operationName = "encode" and
    caughtException = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    operationName = "decode" and
    caughtException = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

// Identifies exception handlers that address a single statement
predicate handles_single_statement(ExceptStmt exceptionHandler, Stmt statement, Expr caughtException) {
  // Confirm that the try block contains exactly one statement
  not exists(exceptionHandler.getTry().getStmt(1)) and
  statement = exceptionHandler.getTry().getStmt(0) and
  exceptionHandler.getType() = caughtException
}

// Detects exception handlers specifically designed for particular operations
predicate is_specialized_exception_handler(ExceptStmt exceptionHandler) {
  // Identify specific exception handling patterns
  exists(Stmt statement, Expr caughtException | 
    handles_single_statement(exceptionHandler, statement, caughtException) |
    // Subscript operations with IndexError
    involves_subscript_operation(statement) and
    caughtException = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    involves_attribute_access(statement) and
    caughtException = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    statement.(ExprStmt).getValue() instanceof Name and
    caughtException = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    is_codec_related_operation(statement.(ExprStmt).getValue(), caughtException)
  )
}

// Main query to identify problematic empty exception handlers
from ExceptStmt exceptionHandler
where
  // Primary conditions: empty exception handler without else clause or explanatory comments
  is_empty_except_block(exceptionHandler) and
  lacks_else_clause(exceptionHandler) and
  has_no_explanatory_comment(exceptionHandler) and
  // Exclude handlers for non-local control flow
  not manages_control_flow_exceptions(exceptionHandler) and
  // Ensure try block has a normal execution path
  has_normal_exit_path(exceptionHandler.getTry()) and
  // Exclude specialized exception handlers
  not is_specialized_exception_handler(exceptionHandler)
select exceptionHandler, "'except' clause does nothing but pass and there is no explanatory comment."