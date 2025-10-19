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
 * Converts dictionary keys to a normalized string format for comparison.
 * Handles numeric literals and string literals (including byte and unicode strings).
 */
predicate normalizedKeyFormat(Dict dictLiteral, Expr key, string normalizedValue) {
  key = dictLiteral.getAKey() and
  (
    // Numeric keys: convert directly to string representation
    normalizedValue = key.(Num).getN()
    or
    // String literals: add type prefix and validate content
    not "�" = normalizedValue.charAt(_) and
    exists(StringLiteral str | 
      str = key and
      (
        // Unicode strings: prefix with 'u'
        normalizedValue = "u\"" + str.getText() + "\"" and str.isUnicode()
        or
        // Byte strings: prefix with 'b'
        normalizedValue = "b\"" + str.getText() + "\"" and not str.isUnicode()
      )
    )
  )
}

// Find dictionary literals with duplicate keys
from Dict dictLiteral, Expr originalKey, Expr duplicateKey
where
  // Both keys have identical normalized representations
  exists(string normalizedValue | 
    normalizedKeyFormat(dictLiteral, originalKey, normalizedValue) and 
    normalizedKeyFormat(dictLiteral, duplicateKey, normalizedValue) and 
    originalKey != duplicateKey
  ) and
  // Verify the ordering relationship between keys
  (
    // Case 1: Keys in same basic block with originalKey before duplicateKey
    exists(BasicBlock block, int originalPos, int duplicatePos |
      originalKey.getAFlowNode() = block.getNode(originalPos) and
      duplicateKey.getAFlowNode() = block.getNode(duplicatePos) and
      originalPos < duplicatePos
    )
    or
    // Case 2: Original key's block strictly dominates duplicate key's block
    originalKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )

// Report the first occurrence of the duplicate key and indicate which later key overwrites it
select originalKey, 
       "Dictionary key " + repr(originalKey) + " is subsequently $@.", 
       duplicateKey, 
       "overwritten"