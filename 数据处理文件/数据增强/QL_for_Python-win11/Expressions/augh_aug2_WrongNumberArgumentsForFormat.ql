/**
 * @name Incorrect argument count in string formatting
 * @description Identifies string formatting operations that have a mismatch between the number 
 *              of conversion specifiers in the format string and the number of values provided 
 *              for formatting. Such mismatches result in TypeError exceptions at runtime.
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
 * Locates string formatting expressions utilizing the % operator.
 * @param formatOperation - The binary expression representing the formatting operation
 * @param formatStringLiteral - The literal string serving as the format template
 * @param formatArguments - The collection of values to be formatted
 * @param argumentsSource - The AST node from which the arguments originate
 */
predicate isPercentFormatOperation(BinaryExpr formatOperation, StringLiteral formatStringLiteral, Value formatArguments, AstNode argumentsSource) {
  // Confirm the operator is the modulo symbol (%)
  formatOperation.getOp() instanceof Mod and
  exists(Context evalContext |
    // Link the left operand to the format string literal
    formatOperation.getLeft().pointsTo(evalContext, _, formatStringLiteral) and
    // Link the right operand to the argument values
    formatOperation.getRight().pointsTo(evalContext, formatArguments, argumentsSource)
  )
}

/**
 * Determines the actual count of arguments in the argument sequence.
 * @param formatArguments - The value representing the arguments
 * @return The quantity of arguments within the sequence
 */
int calculateArgumentCount(Value formatArguments) {
  // Process tuple-type arguments (excluding starred expressions)
  exists(Tuple argTuple | argTuple.pointsTo(formatArguments, _) |
    result = strictcount(argTuple.getAnElt()) and
    not argTuple.getAnElt() instanceof Starred
  )
  or
  // Process individual literal arguments
  exists(ImmutableLiteral singleArg | singleArg.getLiteralValue() = formatArguments | result = 1)
}

from
  BinaryExpr formattingExpr, StringLiteral formatStr, Value argumentValues, 
  int providedArgsCount, int expectedArgsCount, AstNode argumentsSource, string pluralSuffix
where
  // Detect percent-style formatting operations
  isPercentFormatOperation(formattingExpr, formatStr, argumentValues, argumentsSource) and
  // Compute the count of supplied arguments
  providedArgsCount = calculateArgumentCount(argumentValues) and
  // Enumerate the format specifiers in the template string
  expectedArgsCount = format_items(formatStr) and
  // Identify discrepancy between argument count and format specifiers
  providedArgsCount != expectedArgsCount and
  // Construct appropriate message suffix based on argument count
  (if providedArgsCount = 1 then pluralSuffix = " is provided." else pluralSuffix = " are provided.")
select formattingExpr,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    expectedArgsCount.toString() + " values, but " + providedArgsCount.toString() + pluralSuffix, 
  argumentsSource, "arguments", formatStr, formatStr.getText()