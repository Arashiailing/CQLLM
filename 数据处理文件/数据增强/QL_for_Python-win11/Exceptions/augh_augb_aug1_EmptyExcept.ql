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

// Determines if an exception block exclusively contains pass statements
predicate has_only_pass_statements(ExceptStmt exceptionHandler) {
  // Ensure every statement inside the except block is a pass statement
  forall(Stmt statement | statement = exceptionHandler.getAStmt() | statement instanceof Pass)
}

// Checks if a try-except construct lacks an else clause
predicate lacks_else_clause(ExceptStmt exceptionHandler) { 
  // Verify the associated try statement has no else block
  not exists(exceptionHandler.getTry().getOrelse()) 
}

// Detects if there are no explanatory comments within the exception handler
predicate has_no_explanatory_comments(ExceptStmt exceptionHandler) {
  // Confirm absence of any comments within the exception handler's scope
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptionHandler.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptionHandler.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptionHandler.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Identifies exception handlers that deal with non-local control flow exceptions
predicate handles_non_local_control_flow(ExceptStmt exceptionHandler) {
  // Check if the handler catches StopIteration exceptions
  exceptionHandler.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Verifies if a try block has normal execution paths (non-exceptional exits)
predicate has_normal_exit_paths(Try tryBlock) {
  // Identify control flow transitions that represent normal execution
  exists(ControlFlowNode predecessor, ControlFlowNode successor |
    /* Standard control flow edge (not exceptional) */
    predecessor.getASuccessor() = successor and
    not predecessor.getAnExceptionalSuccessor() = successor
  |
    /* Successor is not a return statement */
    not exists(Scope scope | scope.getReturnNode() = successor) and
    /* Predecessor is within try block, successor is outside */
    predecessor.getNode().getParentNode*() = tryBlock.getAStmt() and
    not successor.getNode().getParentNode*() = tryBlock.getAStmt()
  )
}

// Detects statements that perform attribute access operations
predicate performs_attribute_access(Stmt statement) {
  // Direct attribute access or getattr/setattr/delattr function calls
  statement.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string methodName | 
    statement.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = methodName |
    methodName = "getattr" or methodName = "setattr" or methodName = "delattr"
  )
  or
  statement.(Delete).getATarget() instanceof Attribute
}

// Detects statements that perform subscript operations
predicate performs_subscript_operation(Stmt statement) {
  // Subscript access or deletion
  statement.(ExprStmt).getValue() instanceof Subscript
  or
  statement.(Delete).getATarget() instanceof Subscript
}

// Identifies encode/decode operations and their corresponding exception types
predicate is_codec_related_operation(Call callExpression, Expr exceptionType) {
  // Match encode/decode method calls with their specific exception types
  exists(string operationName | 
    callExpression.getFunc().(Attribute).getName() = operationName |
    operationName = "encode" and
    exceptionType = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    operationName = "decode" and
    exceptionType = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

// Identifies exception handlers that guard a single statement
predicate guards_single_statement(ExceptStmt exceptionHandler, Stmt statement, Expr exceptionType) {
  // Verify the try block contains exactly one statement
  not exists(exceptionHandler.getTry().getStmt(1)) and
  statement = exceptionHandler.getTry().getStmt(0) and
  exceptionHandler.getType() = exceptionType
}

// Detects specialized exception handlers tailored for specific operations
predicate is_specialized_exception_handler(ExceptStmt exceptionHandler) {
  // Check for patterns of specific exception handling
  exists(Stmt statement, Expr exceptionType | 
    guards_single_statement(exceptionHandler, statement, exceptionType) |
    // Subscript operations with IndexError
    performs_subscript_operation(statement) and
    exceptionType = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    performs_attribute_access(statement) and
    exceptionType = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    statement.(ExprStmt).getValue() instanceof Name and
    exceptionType = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    is_codec_related_operation(statement.(ExprStmt).getValue(), exceptionType)
  )
}

// Main query to identify problematic empty exception handlers
from ExceptStmt exceptionHandler
where
  // Core conditions: empty exception handler without else clause or comments
  has_only_pass_statements(exceptionHandler) and
  lacks_else_clause(exceptionHandler) and
  has_no_explanatory_comments(exceptionHandler) and
  // Exclude handlers for non-local control flow exceptions
  not handles_non_local_control_flow(exceptionHandler) and
  // Ensure the try block has normal execution paths
  has_normal_exit_paths(exceptionHandler.getTry()) and
  // Exclude specialized exception handlers
  not is_specialized_exception_handler(exceptionHandler)
select exceptionHandler, "'except' clause does nothing but pass and there is no explanatory comment."