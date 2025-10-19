/**
 * @name Wrong number of arguments for format
 * @description Detects string formatting operations where the number of conversion specifiers 
 *              in the format string does not match the number of provided values, which would
 *              result in a TypeError at runtime.
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
 * Helper predicate to identify string formatting operations using the % operator.
 * This predicate captures the relationship between the formatting operation, 
 * the format string, the arguments, and their source location.
 */
predicate isStringFormatOperation(BinaryExpr formatOperation, StringLiteral formatString, 
                                Value formatArguments, AstNode argSource) {
  // Ensure the operation is a modulo (%) operator used for string formatting
  formatOperation.getOp() instanceof Mod and
  exists(Context context |
    // Connect the left operand to the format string literal
    formatOperation.getLeft().pointsTo(context, _, formatString) and
    // Connect the right operand to the provided arguments
    formatOperation.getRight().pointsTo(context, formatArguments, argSource)
  )
}

/**
 * Calculates the length of the argument sequence used in string formatting.
 * Handles different types of argument containers, including tuples and literals.
 */
int getArgumentSequenceLength(Value formatArguments) {
  // Case 1: Arguments are provided as a tuple
  exists(Tuple argumentTuple | argumentTuple.pointsTo(formatArguments, _) |
    result = strictcount(argumentTuple.getAnElt()) and
    // Ensure we don't count starred expressions (*args) as multiple items
    not argumentTuple.getAnElt() instanceof Starred
  )
  or
  // Case 2: Arguments are provided as a single immutable literal
  exists(ImmutableLiteral literal | literal.getLiteralValue() = formatArguments | result = 1)
}

from
  BinaryExpr formatOperation, StringLiteral formatString, Value formatArguments, 
  int sequenceLength, int formatItemCount, AstNode argSource, string providedText
where
  // Identify string formatting operations
  isStringFormatOperation(formatOperation, formatString, formatArguments, argSource) and
  // Calculate the length of the provided argument sequence
  sequenceLength = getArgumentSequenceLength(formatArguments) and
  // Determine the number of format specifiers in the format string
  formatItemCount = format_items(formatString) and
  // Check for mismatch between format specifiers and provided arguments
  sequenceLength != formatItemCount and
  // Generate appropriate text based on the argument count (singular or plural)
  (if sequenceLength = 1 then providedText = " is provided." else providedText = " are provided.")
select formatOperation,
  // Generate error message with details about the mismatch
  "Wrong number of $@ for string format. Format $@ takes " + formatItemCount.toString() + ", but " +
    sequenceLength.toString() + providedText, argSource, "arguments", formatString, formatString.getText()