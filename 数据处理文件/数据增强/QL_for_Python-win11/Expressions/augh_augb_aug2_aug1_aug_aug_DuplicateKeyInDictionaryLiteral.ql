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
 * This predicate handles various key types including numeric literals and string literals
 * (both byte strings and unicode strings).
 */
predicate normalizedKeyFormat(Dict dictionaryLiteral, Expr key, string normalizedValue) {
  key = dictionaryLiteral.getAKey() and
  (
    // For numeric keys, convert the value directly to string
    normalizedValue = key.(Num).getN()
    or
    // For string literals, add appropriate type prefix and validate content
    not "�" = normalizedValue.charAt(_) and
    exists(StringLiteral str | 
      str = key and
      (
        // Unicode strings get 'u' prefix
        normalizedValue = "u\"" + str.getText() + "\"" and str.isUnicode()
        or
        // Byte strings get 'b' prefix
        normalizedValue = "b\"" + str.getText() + "\"" and not str.isUnicode()
      )
    )
  )
}

/**
 * Identifies dictionary literals with duplicate keys by checking for keys with
 * identical normalized representations and verifying their ordering relationship.
 */
from Dict dictionaryLiteral, Expr initialKey, Expr duplicateKey
where
  // Both keys have the same normalized representation
  exists(string normalizedValue | 
    normalizedKeyFormat(dictionaryLiteral, initialKey, normalizedValue) and 
    normalizedKeyFormat(dictionaryLiteral, duplicateKey, normalizedValue) and 
    initialKey != duplicateKey
  ) and
  // Verify the ordering relationship between the keys
  (
    // Case 1: Keys are in the same basic block with initialKey appearing before duplicateKey
    exists(BasicBlock codeBlock, int initialPosition, int duplicatePosition |
      initialKey.getAFlowNode() = codeBlock.getNode(initialPosition) and
      duplicateKey.getAFlowNode() = codeBlock.getNode(duplicatePosition) and
      initialPosition < duplicatePosition
    )
    or
    // Case 2: The basic block containing initialKey strictly dominates the block containing duplicateKey
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )

// Report the first occurrence of the duplicate key and indicate which later key overwrites it
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       duplicateKey, 
       "overwritten"