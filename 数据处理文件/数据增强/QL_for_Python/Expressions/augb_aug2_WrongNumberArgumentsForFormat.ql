/**
 * @name Wrong number of arguments for format
 * @description Identifies string formatting operations where the count of conversion specifiers 
 *              in the format string doesn't match the count of values to be formatted. 
 *              This results in a TypeError at runtime.
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
 * @param binExpr - The binary expression containing the formatting operation
 * @param fmtString - The format string literal
 * @param argsToFormat - The values to be formatted
 * @param argsSource - The AST node where the arguments originate
 */
predicate detectPercentFormatOperation(BinaryExpr binExpr, StringLiteral fmtString, Value argsToFormat, AstNode argsSource) {
  // Confirm the operator is modulo (%)
  binExpr.getOp() instanceof Mod and
  exists(Context evalContext |
    // Trace the left operand to the format string literal
    binExpr.getLeft().pointsTo(evalContext, _, fmtString) and
    // Trace the right operand to the argument values
    binExpr.getRight().pointsTo(evalContext, argsToFormat, argsSource)
  )
}

/**
 * Computes the effective length of the argument sequence.
 * @param argsValue - The value representing the arguments
 * @return The count of arguments in the sequence
 */
int computeArgumentCount(Value argsValue) {
  // Process tuple arguments (excluding starred expressions)
  exists(Tuple argTuple | argTuple.pointsTo(argsValue, _) |
    result = strictcount(argTuple.getAnElt()) and
    not argTuple.getAnElt() instanceof Starred
  )
  or
  // Process single literal arguments
  exists(ImmutableLiteral singleLiteral | singleLiteral.getLiteralValue() = argsValue | result = 1)
}

from
  BinaryExpr formatOperation, StringLiteral formatLiteral, Value formattingArguments, 
  int providedArgCount, int expectedFormatCount, AstNode argumentsSource, string pluralSuffix
where
  // Identify percent-style formatting operations
  detectPercentFormatOperation(formatOperation, formatLiteral, formattingArguments, argumentsSource) and
  // Calculate the number of provided arguments
  providedArgCount = computeArgumentCount(formattingArguments) and
  // Count the format specifiers in the string
  expectedFormatCount = format_items(formatLiteral) and
  // Detect mismatch between argument count and format specifiers
  providedArgCount != expectedFormatCount and
  // Generate appropriate message suffix based on argument count
  (if providedArgCount = 1 then pluralSuffix = " is provided." else pluralSuffix = " are provided.")
select formatOperation,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    expectedFormatCount.toString() + " values, but " + providedArgCount.toString() + pluralSuffix, 
  argumentsSource, "arguments", formatLiteral, formatLiteral.getText()