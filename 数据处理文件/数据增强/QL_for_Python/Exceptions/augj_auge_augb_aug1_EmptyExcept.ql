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

// Check if an exception handler contains only pass statements
predicate contains_only_pass_statements(ExceptStmt exceptBlock) {
  // Ensure all statements in the exception handler are pass statements
  not exists(Stmt stmt | 
    stmt = exceptBlock.getAStmt() and 
    not stmt instanceof Pass
  )
}

// Determine if a try-except construct has no else clause
predicate has_no_else_clause(ExceptStmt exceptBlock) { 
  // Verify that the try statement does not have an associated else block
  not exists(exceptBlock.getTry().getOrelse()) 
}

// Verify that there are no explanatory comments within the exception handler
predicate lacks_explanatory_comments(ExceptStmt exceptBlock) {
  // Confirm that no comments are present within the exception handler's boundaries
  not exists(Comment comment |
    comment.getLocation().getFile() = exceptBlock.getLocation().getFile() and
    comment.getLocation().getStartLine() >= exceptBlock.getLocation().getStartLine() and
    comment.getLocation().getEndLine() <= exceptBlock.getBody().getLastItem().getLocation().getEndLine()
  )
}

// Identify exception handlers that manage non-local control flow exceptions
predicate handles_control_flow_exceptions(ExceptStmt exceptBlock) {
  // Detect handling of StopIteration exceptions
  exceptBlock.getType() = API::builtin("StopIteration").getAValueReachableFromSource().asExpr()
}

// Check if normal execution can exit from the try block
predicate has_normal_execution_exit(Try tryStmt) {
  // Identify non-exceptional control flow transitions
  exists(ControlFlowNode prevNode, ControlFlowNode nextNode |
    /* Standard (non-exceptional) control flow connection */
    prevNode.getASuccessor() = nextNode and
    not prevNode.getAnExceptionalSuccessor() = nextNode
  |
    /* Valid next node: not a return statement */
    not exists(Scope scope | scope.getReturnNode() = nextNode) and
    /* Prior node in try body, next node outside */
    prevNode.getNode().getParentNode*() = tryStmt.getAStmt() and
    not nextNode.getNode().getParentNode*() = tryStmt.getAStmt()
  )
}

// Detect attribute access operations within statements
predicate contains_attribute_access(Stmt stmt) {
  // Direct attribute access or getattr/setattr/delattr invocations
  stmt.(ExprStmt).getValue() instanceof Attribute
  or
  exists(string methodName | 
    stmt.(ExprStmt).getValue().(Call).getFunc().(Name).getId() = methodName |
    methodName = "getattr" or methodName = "setattr" or methodName = "delattr"
  )
  or
  stmt.(Delete).getATarget() instanceof Attribute
}

// Identify subscript operations within statements
predicate contains_subscript_operation(Stmt stmt) {
  // Subscript access or deletion
  stmt.(ExprStmt).getValue() instanceof Subscript
  or
  stmt.(Delete).getATarget() instanceof Subscript
}

// Match encode/decode operations with their corresponding exception types
predicate is_codec_operation(Call methodCall, Expr caughtException) {
  // Associate encode/decode calls with appropriate exception types
  exists(string opName | 
    methodCall.getFunc().(Attribute).getName() = opName |
    opName = "encode" and
    caughtException = API::builtin("UnicodeEncodeError").getAValueReachableFromSource().asExpr()
    or
    opName = "decode" and
    caughtException = API::builtin("UnicodeDecodeError").getAValueReachableFromSource().asExpr()
  )
}

// Identify exception handlers that address a single statement
predicate handles_single_stmt(ExceptStmt exceptBlock, Stmt stmt, Expr caughtException) {
  // Confirm that the try block contains exactly one statement
  not exists(exceptBlock.getTry().getStmt(1)) and
  stmt = exceptBlock.getTry().getStmt(0) and
  exceptBlock.getType() = caughtException
}

// Detect exception handlers specifically designed for particular operations
predicate is_specialized_handler(ExceptStmt exceptBlock) {
  // Identify specific exception handling patterns
  exists(Stmt stmt, Expr caughtException | 
    handles_single_stmt(exceptBlock, stmt, caughtException) |
    // Subscript operations with IndexError
    contains_subscript_operation(stmt) and
    caughtException = API::builtin("IndexError").getASubclass*().getAValueReachableFromSource().asExpr()
    or
    // Attribute access with AttributeError
    contains_attribute_access(stmt) and
    caughtException = API::builtin("AttributeError").getAValueReachableFromSource().asExpr()
    or
    // Name access with NameError
    stmt.(ExprStmt).getValue() instanceof Name and
    caughtException = API::builtin("NameError").getAValueReachableFromSource().asExpr()
    or
    // Encoding/decoding operations
    is_codec_operation(stmt.(ExprStmt).getValue(), caughtException)
  )
}

// Main query to identify problematic empty exception handlers
from ExceptStmt exceptBlock
where
  // Primary conditions: empty exception handler without else clause or explanatory comments
  contains_only_pass_statements(exceptBlock) and
  has_no_else_clause(exceptBlock) and
  lacks_explanatory_comments(exceptBlock) and
  // Exclude handlers for non-local control flow
  not handles_control_flow_exceptions(exceptBlock) and
  // Ensure try block has a normal execution path
  has_normal_execution_exit(exceptBlock.getTry()) and
  // Exclude specialized exception handlers
  not is_specialized_handler(exceptBlock)
select exceptBlock, "'except' clause does nothing but pass and there is no explanatory comment."