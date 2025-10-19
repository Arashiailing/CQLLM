/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where initial values are silently replaced by subsequent ones.
 * @kind problem
 * @tags reliability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/duplicate-key-dict-literal
 */

import python
import semmle.python.strings

/**
 * Converts dictionary keys into normalized string formats to enable accurate comparison.
 * Handles numeric types (direct value conversion) and string literals (with type-specific prefixes).
 */
predicate keyNormalization(Dict dictionary, Expr keyExpr, string normalizedKey) {
  keyExpr = dictionary.getAKey() and
  (
    // Handle numeric keys by converting their value to string representation
    normalizedKey = keyExpr.(Num).getN()
    or
    // Process string literals with appropriate type prefixes
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpr and
      (
        // Unicode strings get 'u"' prefix
        normalizedKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings get 'b"' prefix
        normalizedKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Identify dictionary keys that are duplicated and overwrite previous occurrences
from Dict dictionary, Expr firstKey, Expr secondKey
where
  // Both keys must have identical normalized representations
  exists(string keySignature | 
    keyNormalization(dictionary, firstKey, keySignature) and 
    keyNormalization(dictionary, secondKey, keySignature) and 
    firstKey != secondKey
  ) and
  // Validate the temporal sequence of key occurrences
  (
    // Scenario 1: Keys exist within the same basic block with first key appearing first
    exists(BasicBlock basicBlock, int firstPosition, int secondPosition |
      firstKey.getAFlowNode() = basicBlock.getNode(firstPosition) and
      secondKey.getAFlowNode() = basicBlock.getNode(secondPosition) and
      firstPosition < secondPosition
    )
    or
    // Scenario 2: First key's basic block strictly dominates second key's basic block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location of the overwriting duplicate
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"