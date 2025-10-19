/**
 * @name Incorrect argument count for percent formatting
 * @description Identifies string formatting operations using % operator where the number of 
 *              format specifiers doesn't match the number of provided arguments. 
 *              This mismatch causes a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/percent-format/wrong-arguments
 */

import python
import semmle.python.strings

/**
 * Detects string formatting operations using the % operator.
 * @param expr - Binary expression representing the formatting operation
 * @param formatStr - Format string literal
 * @param argsVal - Values to be formatted
 * @param argsSrc - AST node containing the arguments
 */
predicate isPercentFormatExpr(BinaryExpr expr, StringLiteral formatStr, Value argsVal, AstNode argsSrc) {
  // Verify modulo operator usage
  expr.getOp() instanceof Mod and
  exists(Context ctx |
    // Resolve left operand to format string
    expr.getLeft().pointsTo(ctx, _, formatStr) and
    // Resolve right operand to argument values
    expr.getRight().pointsTo(ctx, argsVal, argsSrc)
  )
}

/**
 * Calculates the number of arguments in the provided value.
 * @param argsVal - Value representing the arguments
 * @return Count of arguments in the sequence
 */
int countArguments(Value argsVal) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple argTuple | argTuple.pointsTo(argsVal, _) |
    result = strictcount(argTuple.getAnElt()) and
    not argTuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral literal | literal.getLiteralValue() = argsVal | result = 1)
}

from
  BinaryExpr formatExpr, StringLiteral formatString, Value argsValue, 
  int providedArgsCount, int expectedArgsCount, AstNode argsSource, string msgSuffix
where
  // Identify percent-style formatting operations
  isPercentFormatExpr(formatExpr, formatString, argsValue, argsSource) and
  // Calculate provided argument count
  providedArgsCount = countArguments(argsValue) and
  // Count format specifiers in the string
  expectedArgsCount = format_items(formatString) and
  // Detect mismatch between arguments and format specifiers
  providedArgsCount != expectedArgsCount and
  // Generate appropriate message suffix
  (if providedArgsCount = 1 then msgSuffix = " is provided." else msgSuffix = " are provided.")
select formatExpr,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    expectedArgsCount.toString() + " values, but " + providedArgsCount.toString() + msgSuffix, 
  argsSource, "arguments", formatString, formatString.getText()