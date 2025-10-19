/**
 * @name Mismatched argument count in percent formatting
 * @description Identifies string formatting using % operator where conversion specifier 
 *              count in format string doesn't match provided argument count. 
 *              This mismatch causes runtime TypeError.
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
 * Detects percent-style string formatting operations.
 * @param fmtExpr - Binary expression representing formatting operation
 * @param fmtStrLiteral - Format string literal used in operation
 * @param argValues - Values intended for formatting
 * @param argSrc - AST node representing argument source
 */
predicate isPercentFormatOperation(BinaryExpr fmtExpr, StringLiteral fmtStrLiteral, Value argValues, AstNode argSrc) {
  // Verify modulo operator usage
  fmtExpr.getOp() instanceof Mod and
  exists(Context context |
    // Resolve left operand to format string literal
    fmtExpr.getLeft().pointsTo(context, _, fmtStrLiteral) and
    // Resolve right operand to argument values
    fmtExpr.getRight().pointsTo(context, argValues, argSrc)
  )
}

/**
 * Computes actual argument count in sequence.
 * @param argValues - Value representing argument sequence
 * @return Number of arguments present
 */
int getArgumentCount(Value argValues) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple tuple | tuple.pointsTo(argValues, _) |
    result = strictcount(tuple.getAnElt()) and
    not tuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral literal | literal.getLiteralValue() = argValues | result = 1)
}

from
  BinaryExpr formatExpr, StringLiteral fmtStr, Value argValues, 
  int argCount, int specCount, AstNode argSrcNode, string msgSuffix
where
  // Identify percent-style formatting operations
  isPercentFormatOperation(formatExpr, fmtStr, argValues, argSrcNode) and
  // Calculate provided argument count
  argCount = getArgumentCount(argValues) and
  // Count format specifiers in the string
  specCount = format_items(fmtStr) and
  // Detect mismatch between arguments and format specifiers
  argCount != specCount and
  // Generate context-aware message suffix
  (if argCount = 1 then msgSuffix = " is provided." else msgSuffix = " are provided.")
select formatExpr,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    specCount.toString() + " values, but " + argCount.toString() + msgSuffix, 
  argSrcNode, "arguments", fmtStr, fmtStr.getText()