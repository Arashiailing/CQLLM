/**
 * @name Wrong number of arguments for format
 * @description Identifies string formatting operations where the count of conversion specifiers 
 *              in the format string doesn't match the count of values to be formatted. 
 *              This results in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/percent-format/wrong-arguments
 */

import python
import semmle.python.strings

/**
 * Identifies string formatting operations that use the % operator.
 * This predicate captures the binary expression, the format string literal, 
 * the values to be formatted, and the AST node where these values originate.
 * @param binExpr - The binary expression containing the formatting operation
 * @param fmtString - The format string literal
 * @param argsToFormat - The values to be formatted
 * @param argsSource - The AST node where the arguments originate
 */
predicate detectPercentFormatOperation(BinaryExpr binExpr, StringLiteral fmtString, Value argsToFormat, AstNode argsSource) {
  // Verify that the operator is the modulo (%), used for string formatting
  binExpr.getOp() instanceof Mod and
  exists(Context evaluationContext |
    // Resolve the left operand to the format string literal
    binExpr.getLeft().pointsTo(evaluationContext, _, fmtString) and
    // Resolve the right operand to the values to be formatted
    binExpr.getRight().pointsTo(evaluationContext, argsToFormat, argsSource)
  )
}

/**
 * Calculates the effective number of arguments provided for formatting.
 * This predicate handles both tuple arguments (excluding starred expressions) 
 * and single literal arguments.
 * @param argsValue - The value representing the arguments
 * @return The count of arguments in the sequence
 */
int computeArgumentCount(Value argsValue) {
  // First, check if the arguments are provided as a tuple
  exists(Tuple argumentTuple | 
    argumentTuple.pointsTo(argsValue, _) and
    // Exclude starred expressions from the count
    not argumentTuple.getAnElt() instanceof Starred
  |
    result = strictcount(argumentTuple.getAnElt())
  )
  or
  // If not a tuple, check if it's a single literal argument
  exists(ImmutableLiteral singleLiteralArgument | 
    singleLiteralArgument.getLiteralValue() = argsValue 
  |
    result = 1
  )
}

from
  BinaryExpr formatOperation, StringLiteral formatLiteral, Value formattingArguments, 
  int providedArgCount, int expectedFormatCount, AstNode argumentsSource, string pluralSuffix
where
  // Identify percent-style string formatting operations
  detectPercentFormatOperation(formatOperation, formatLiteral, formattingArguments, argumentsSource) and
  // Calculate the number of arguments provided for formatting
  providedArgCount = computeArgumentCount(formattingArguments) and
  // Count the format specifiers in the format string
  expectedFormatCount = format_items(formatLiteral) and
  // Detect mismatch between argument count and format specifiers
  providedArgCount != expectedFormatCount and
  // Generate appropriate message suffix based on argument count
  (if providedArgCount = 1 then pluralSuffix = " is provided." else pluralSuffix = " are provided.")
select formatOperation,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    expectedFormatCount.toString() + " values, but " + providedArgCount.toString() + pluralSuffix, 
  argumentsSource, "arguments", formatLiteral, formatLiteral.getText()