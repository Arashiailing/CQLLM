/**
 * @name Incorrect argument count for percent formatting
 * @description Detects string formatting operations using the % operator where 
 *              the number of conversion specifiers in the format string 
 *              does not match the number of provided arguments. 
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
 * Identifies percent-style string formatting operations.
 * @param formatOperation - Binary expression representing the formatting operation
 * @param formatStringLiteral - Format string literal used in the operation
 * @param argumentValues - Values intended for formatting
 * @param argumentSource - AST node representing the argument source
 */
predicate isPercentFormatOperation(BinaryExpr formatOperation, StringLiteral formatStringLiteral, Value argumentValues, AstNode argumentSource) {
  // Verify modulo operator usage
  formatOperation.getOp() instanceof Mod and
  exists(Context context |
    // Resolve left operand to format string literal
    formatOperation.getLeft().pointsTo(context, _, formatStringLiteral) and
    // Resolve right operand to argument values
    formatOperation.getRight().pointsTo(context, argumentValues, argumentSource)
  )
}

/**
 * Calculates the actual number of arguments in the sequence.
 * @param argumentValues - Value representing the argument sequence
 * @return Number of arguments present
 */
int getArgumentCount(Value argumentValues) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple tuple | tuple.pointsTo(argumentValues, _) |
    result = strictcount(tuple.getAnElt()) and
    not tuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral literal | literal.getLiteralValue() = argumentValues | result = 1)
}

from
  BinaryExpr formattingOperation, StringLiteral formatString, Value arguments, 
  int argumentCount, int specifierCount, AstNode argumentSourceNode, string messageSuffix
where
  // Identify percent-style formatting operations
  isPercentFormatOperation(formattingOperation, formatString, arguments, argumentSourceNode) and
  // Calculate provided argument count
  argumentCount = getArgumentCount(arguments) and
  // Count format specifiers in the string
  specifierCount = format_items(formatString) and
  // Detect mismatch between arguments and format specifiers
  argumentCount != specifierCount and
  // Generate context-aware message suffix
  (if argumentCount = 1 then messageSuffix = " is provided." else messageSuffix = " are provided.")
select formattingOperation,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    specifierCount.toString() + " values, but " + argumentCount.toString() + messageSuffix, 
  argumentSourceNode, "arguments", formatString, formatString.getText()