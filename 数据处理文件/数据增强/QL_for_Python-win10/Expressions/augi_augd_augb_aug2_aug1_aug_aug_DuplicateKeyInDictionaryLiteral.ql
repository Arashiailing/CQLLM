/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys, where earlier key-value pairs are silently overwritten by later ones.
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
 * Converts dictionary keys to a standardized string representation for comparison.
 * This predicate handles different types of key expressions including numeric literals
 * and string literals (both byte and unicode strings).
 */
predicate getNormalizedKeyString(Dict dictionaryLiteral, Expr keyExpression, string normalizedKeyRepresentation) {
  keyExpression = dictionaryLiteral.getAKey() and
  (
    // Handle numeric keys by converting their value directly to string
    normalizedKeyRepresentation = keyExpression.(Num).getN()
    or
    // Handle string literals by adding appropriate type prefix
    not "�" = normalizedKeyRepresentation.charAt(_) and
    exists(StringLiteral stringLiteral | 
      stringLiteral = keyExpression and
      (
        // For unicode strings, prefix with 'u'
        normalizedKeyRepresentation = "u\"" + stringLiteral.getText() + "\"" and stringLiteral.isUnicode()
        or
        // For byte strings, prefix with 'b'
        normalizedKeyRepresentation = "b\"" + stringLiteral.getText() + "\"" and not stringLiteral.isUnicode()
      )
    )
  )
}

/**
 * Main query to identify dictionary literals with duplicate keys.
 * The query checks for keys that have the same normalized representation
 * and verifies their ordering in the code.
 */
from Dict dictionaryLiteral, Expr firstKeyInstance, Expr duplicateKeyInstance
where
  // Find keys with identical normalized representation
  exists(string normalizedKeyRepresentation | 
    getNormalizedKeyString(dictionaryLiteral, firstKeyInstance, normalizedKeyRepresentation) and 
    getNormalizedKeyString(dictionaryLiteral, duplicateKeyInstance, normalizedKeyRepresentation) and 
    firstKeyInstance != duplicateKeyInstance
  ) and
  // Ensure proper ordering of keys in the code
  (
    // Case 1: Keys are in the same basic block with firstKeyInstance appearing before duplicateKeyInstance
    exists(BasicBlock codeBlock, int firstKeyPosition, int duplicateKeyPosition |
      firstKeyInstance.getAFlowNode() = codeBlock.getNode(firstKeyPosition) and
      duplicateKeyInstance.getAFlowNode() = codeBlock.getNode(duplicateKeyPosition) and
      firstKeyPosition < duplicateKeyPosition
    )
    or
    // Case 2: The basic block containing firstKeyInstance strictly dominates the block containing duplicateKeyInstance
    firstKeyInstance.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKeyInstance.getAFlowNode().getBasicBlock()
    )
  )

// Generate alert message pointing to the first occurrence of the duplicate key
// and indicating which later key overwrites it
select firstKeyInstance, 
       "Dictionary key " + repr(firstKeyInstance) + " is subsequently $@.", 
       duplicateKeyInstance, 
       "overwritten"