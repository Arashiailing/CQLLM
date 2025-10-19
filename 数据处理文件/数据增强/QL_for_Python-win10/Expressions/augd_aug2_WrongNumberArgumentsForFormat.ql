/**
 * @name Wrong number of arguments for format
 * @description Identifies string formatting operations using the % operator where the quantity 
 *              of conversion specifiers in the format string does not match the quantity of 
 *              provided values. This mismatch results in a TypeError at runtime.
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
 * Locates string formatting expressions that utilize the % operator.
 * @param formatOperation - The binary expression representing the formatting operation
 * @param formatStringLiteral - The literal string used as the format template
 * @param formatArguments - The collection of values to be formatted
 * @param argumentSource - The AST node from which the arguments originate
 */
predicate isPercentFormatOperation(BinaryExpr formatOperation, StringLiteral formatStringLiteral, 
                                  Value formatArguments, AstNode argumentSource) {
  // Confirm the operation uses the modulo (%) operator
  formatOperation.getOp() instanceof Mod and
  exists(Context evaluationContext |
    // Resolve the left operand to the format string literal
    formatOperation.getLeft().pointsTo(evaluationContext, _, formatStringLiteral) and
    // Resolve the right operand to the argument values
    formatOperation.getRight().pointsTo(evaluationContext, formatArguments, argumentSource)
  )
}

/**
 * Computes the actual number of arguments provided for formatting.
 * @param formatArguments - The value representing the arguments to be formatted
 * @return The count of arguments in the provided sequence
 */
int calculateArgumentCount(Value formatArguments) {
  // Process tuple arguments (excluding starred expressions)
  exists(Tuple argumentTuple | argumentTuple.pointsTo(formatArguments, _) |
    result = strictcount(argumentTuple.getAnElt()) and
    not argumentTuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral literalArgument | literalArgument.getLiteralValue() = formatArguments | result = 1)
}

from
  BinaryExpr formatExpression, StringLiteral formatString, Value argumentsValue, 
  int providedArgumentCount, int formatSpecifierCount, AstNode argumentSourceNode, 
  string messageVerbSuffix
where
  // Detect percent-style formatting operations
  isPercentFormatOperation(formatExpression, formatString, argumentsValue, argumentSourceNode) and
  // Determine the count of provided arguments
  providedArgumentCount = calculateArgumentCount(argumentsValue) and
  // Count the format specifiers in the template string
  formatSpecifierCount = format_items(formatString) and
  // Identify mismatch between argument count and format specifiers
  providedArgumentCount != formatSpecifierCount and
  // Generate appropriate verb for the error message based on argument count
  (if providedArgumentCount = 1 then messageVerbSuffix = " is provided." else messageVerbSuffix = " are provided.")
select formatExpression,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    formatSpecifierCount.toString() + " values, but " + providedArgumentCount.toString() + messageVerbSuffix, 
  argumentSourceNode, "arguments", formatString, formatString.getText()