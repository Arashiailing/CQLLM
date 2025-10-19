/**
 * @name Incorrect argument count for percent formatting
 * @description Identifies string formatting operations using % operator where conversion specifier count 
 *              mismatches provided argument count. Example: '"%s: %s, %s" % (a,b)' triggers TypeError.
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

// Detects percent-style string formatting operations
predicate percent_format_operation(BinaryExpr formatOpExpr, StringLiteral formatString, Value argumentsValue, AstNode argumentsSource) {
  // Verify modulo operator is used
  formatOpExpr.getOp() instanceof Mod and
  exists(Context ctx |
    // Left operand must resolve to format string
    formatOpExpr.getLeft().pointsTo(ctx, _, formatString) and
    // Right operand must resolve to arguments
    formatOpExpr.getRight().pointsTo(ctx, argumentsValue, argumentsSource)
  )
}

// Computes the number of formatting arguments
int count_format_arguments(Value argumentsValue) {
  /* Handle tuple arguments */
  exists(Tuple tupleArg | tupleArg.pointsTo(argumentsValue, _) |
    result = strictcount(tupleArg.getAnElt()) and
    // Exclude starred expressions from count
    not tupleArg.getAnElt() instanceof Starred
  )
  or
  /* Handle single literal arguments */
  exists(ImmutableLiteral literalArg | literalArg.getLiteralValue() = argumentsValue | result = 1)
}

from
  BinaryExpr formatOpExpr, StringLiteral formatString, Value argumentsValue, 
  int argumentsCount, int formatItemsCount, AstNode argumentsSource, string messageEnding
where
  // Identify percent formatting operation
  percent_format_operation(formatOpExpr, formatString, argumentsValue, argumentsSource) and
  // Calculate argument count
  argumentsCount = count_format_arguments(argumentsValue) and
  // Calculate format specifier count
  formatItemsCount = format_items(formatString) and
  // Detect count mismatch
  argumentsCount != formatItemsCount and
  // Generate context-aware message suffix
  (if argumentsCount = 1 then messageEnding = " is provided." else messageEnding = " are provided.")
select formatOpExpr,
  // Construct error message
  "Incorrect number of $@ for string formatting. Format $@ expects " + formatItemsCount.toString() + 
  ", but " + argumentsCount.toString() + messageEnding, 
  argumentsSource, "arguments", formatString, formatString.getText()