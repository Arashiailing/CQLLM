/**
 * @name Incorrect argument count for percent-formatting
 * @description Detects string formatting operations like '"%s: %s, %s" % (a,b)' where the number of format specifiers
 *              mismatches the provided values, causing runtime TypeError.
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

// Predicate identifying string formatting operations using %
predicate percent_format_operation(BinaryExpr expr, StringLiteral formatStr, Value formatArgs, AstNode argsSource) {
  // Verify the operator is modulo (%)
  expr.getOp() instanceof Mod and
  exists(Context ctx |
    // Check left operand resolves to the format string
    expr.getLeft().pointsTo(ctx, _, formatStr) and
    // Check right operand resolves to the format arguments
    expr.getRight().pointsTo(ctx, formatArgs, argsSource)
  )
}

// Calculate the number of elements in a sequence
int get_sequence_size(Value argValue) {
  /* Determine sequence length */
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple tupleLiteral | tupleLiteral.pointsTo(argValue, _) |
    result = strictcount(tupleLiteral.getAnElt()) and
    // Exclude starred expressions from count
    not tupleLiteral.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral singleLiteral | singleLiteral.getLiteralValue() = argValue | result = 1)
}

from
  BinaryExpr formatExpr, StringLiteral formatString, Value arguments, int specifierCount, 
  int providedCount, AstNode argumentSource, string quantityDescription
where
  // Identify percent-formatting operations
  percent_format_operation(formatExpr, formatString, arguments, argumentSource) and
  // Get the count of provided arguments
  providedCount = get_sequence_size(arguments) and
  // Get the count of format specifiers
  specifierCount = format_items(formatString) and
  // Check for mismatched counts
  providedCount != specifierCount and
  // Generate appropriate quantity description
  (if providedCount = 1 then quantityDescription = " is provided." else quantityDescription = " are provided.")
select formatExpr,
  // Generate error message with contextual details
  "Incorrect number of $@ for string format. Format $@ requires " + specifierCount.toString() + 
  ", but " + providedCount.toString() + quantityDescription, 
  argumentSource, "arguments", formatString, formatString.getText()