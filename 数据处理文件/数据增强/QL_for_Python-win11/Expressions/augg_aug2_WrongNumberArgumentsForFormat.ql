/**
 * @name Incorrect argument count for percent formatting
 * @description Identifies string formatting operations using % operator where 
 *              the quantity of conversion specifiers in the format string 
 *              mismatches the quantity of provided values. 
 *              This leads to a TypeError during execution.
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
 * Detects string formatting operations utilizing the % operator.
 * @param expr - Binary expression containing the formatting operation
 * @param fmtLiteral - Format string literal used in operation
 * @param argValues - Values intended for formatting
 * @param argOrigin - AST node representing argument source
 */
predicate canBePercentFormatOperation(BinaryExpr expr, StringLiteral fmtLiteral, Value argValues, AstNode argOrigin) {
  // Confirm modulo operator usage
  expr.getOp() instanceof Mod and
  exists(Context ctx |
    // Resolve left operand to format string literal
    expr.getLeft().pointsTo(ctx, _, fmtLiteral) and
    // Resolve right operand to argument values
    expr.getRight().pointsTo(ctx, argValues, argOrigin)
  )
}

/**
 * Computes the actual quantity of arguments in the sequence.
 * @param argValues - Value representing the argument sequence
 * @return Quantity of arguments present
 */
int computeArgumentCount(Value argValues) {
  // Process tuple arguments (excluding starred expressions)
  exists(Tuple tuple | tuple.pointsTo(argValues, _) |
    result = strictcount(tuple.getAnElt()) and
    not tuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral lit | lit.getLiteralValue() = argValues | result = 1)
}

from
  BinaryExpr formatExpr, StringLiteral fmtStr, Value args, 
  int argCount, int specCount, AstNode argsOrigin, string msgSuffix
where
  // Identify percent-style formatting operations
  canBePercentFormatOperation(formatExpr, fmtStr, args, argsOrigin) and
  // Calculate quantity of provided arguments
  argCount = computeArgumentCount(args) and
  // Count format specifiers in the string
  specCount = format_items(fmtStr) and
  // Detect mismatch between arguments and format specifiers
  argCount != specCount and
  // Generate context-aware message suffix
  (if argCount = 1 then msgSuffix = " is provided." else msgSuffix = " are provided.")
select formatExpr,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    specCount.toString() + " values, but " + argCount.toString() + msgSuffix, 
  argsOrigin, "arguments", fmtStr, fmtStr.getText()