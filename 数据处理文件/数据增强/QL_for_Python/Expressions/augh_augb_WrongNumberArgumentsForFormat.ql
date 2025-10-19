/**
 * @name Wrong number of arguments for format
 * @description Detects string formatting operations where the number of conversion specifiers 
 *              in the format string doesn't match the number of provided values. 
 *              Example: '"%s: %s, %s" % (a,b)' will raise a TypeError.
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

// Identifies string formatting operations using the % operator
predicate format_operation(BinaryExpr binaryExpr, StringLiteral formatLiteral, Value argumentValue, AstNode argSourceNode) {
  // Verify the operator is modulo (%)
  binaryExpr.getOp() instanceof Mod and
  exists(Context context |
    // Check left operand points to the format string
    binaryExpr.getLeft().pointsTo(context, _, formatLiteral) and
    // Check right operand points to the argument value
    binaryExpr.getRight().pointsTo(context, argumentValue, argSourceNode)
  )
}

// Calculates the length of the argument sequence
int argument_count(Value argumentValue) {
  /* Handle tuple arguments */
  exists(Tuple argTuple | argTuple.pointsTo(argumentValue, _) |
    result = strictcount(argTuple.getAnElt()) and
    // Exclude starred expressions from count
    not argTuple.getAnElt() instanceof Starred
  )
  or
  /* Handle single literal arguments */
  exists(ImmutableLiteral argLiteral | argLiteral.getLiteralValue() = argumentValue | result = 1)
}

from
  BinaryExpr formatOperation, StringLiteral formatString, Value argsValue, 
  int providedArgsCount, int expectedArgsCount, AstNode argsSourceNode, string msgSuffix
where
  // Identify format operation
  format_operation(formatOperation, formatString, argsValue, argsSourceNode) and
  // Calculate argument count
  providedArgsCount = argument_count(argsValue) and
  // Calculate format item count
  expectedArgsCount = format_items(formatString) and
  // Validate mismatch
  providedArgsCount != expectedArgsCount and
  // Generate appropriate message suffix
  (if providedArgsCount = 1 then msgSuffix = " is provided." else msgSuffix = " are provided.")
select formatOperation,
  // Construct error message
  "Wrong number of $@ for string format. Format $@ takes " + expectedArgsCount.toString() + 
  ", but " + providedArgsCount.toString() + msgSuffix, 
  argsSourceNode, "arguments", formatString, formatString.getText()