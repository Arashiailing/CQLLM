/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where earlier entries are overwritten by later ones.
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
 * Transforms dictionary keys into standardized string representations for comparison purposes.
 * This predicate handles two types of keys:
 * 1. Numeric keys: Directly converts the numeric value to a string.
 * 2. String literals: Adds type-specific prefixes to distinguish between unicode and byte strings.
 */
predicate standardizedKeyForm(Dict dict, Expr key, string standardizedForm) {
  key = dict.getAKey() and
  (
    // Handle numeric keys by converting their value to string
    standardizedForm = key.(Num).getN()
    or
    // Handle string literals with appropriate type prefixes
    exists(StringLiteral strLiteral | 
      strLiteral = key and
      (
        // Unicode strings get 'u"' prefix
        standardizedForm = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings get 'b"' prefix
        standardizedForm = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

/**
 * Determines if one key occurrence appears before another in the control flow.
 * This predicate checks two scenarios:
 * 1. Both keys are in the same basic block, with the first key at a lower index.
 * 2. The first key's basic block strictly dominates the second key's basic block.
 */
predicate keyPrecedes(Expr initialKey, Expr duplicateKey) {
  // Case 1: Keys appear in the same basic block with the first key at a lower index
  exists(BasicBlock codeBlock, int initialPosition, int duplicatePosition |
    initialKey.getAFlowNode() = codeBlock.getNode(initialPosition) and
    duplicateKey.getAFlowNode() = codeBlock.getNode(duplicatePosition) and
    initialPosition < duplicatePosition
  )
  or
  // Case 2: The first key's block strictly dominates the second key's block
  initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
    duplicateKey.getAFlowNode().getBasicBlock()
  )
}

// Main query to identify duplicate keys in dictionary literals
from Dict dict, Expr initialKey, Expr duplicateKey
where
  // Both keys must have identical standardized representations
  exists(string keySignature | 
    standardizedKeyForm(dict, initialKey, keySignature) and 
    standardizedKeyForm(dict, duplicateKey, keySignature) and 
    initialKey != duplicateKey
  ) and
  // Verify that the initial key appears before the duplicate key
  keyPrecedes(initialKey, duplicateKey)
// Report the overwritten key with location of the overwriting key
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       duplicateKey, 
       "overwritten"