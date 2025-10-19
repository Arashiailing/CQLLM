/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys, where all but the final occurrence are overwritten
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
 * Transforms dictionary keys into their string representations for comparison purposes.
 * This predicate handles both numeric values and string literals (including Unicode and byte strings).
 */
predicate dictKeyToString(Dict dictionary, Expr keyExpression, string keyStringValue) {
  keyExpression = dictionary.getAKey() and
  (
    // Process numeric keys by converting their value to string
    keyStringValue = keyExpression.(Num).getN()
    or
    // Process string keys, handling both Unicode and byte string representations
    // Special character handling: '�' indicates characters that cannot be represented
    not "�" = keyStringValue.charAt(_) and
    exists(StringLiteral stringLiteral | stringLiteral = keyExpression |
      keyStringValue = "u\"" + stringLiteral.getText() + "\"" and stringLiteral.isUnicode()
      or
      keyStringValue = "b\"" + stringLiteral.getText() + "\"" and not stringLiteral.isUnicode()
    )
  )
}

from Dict dictionary, Expr initialKey, Expr subsequentKey, string keyStringValue
where
  // Find two distinct keys with identical string representations
  dictKeyToString(dictionary, initialKey, keyStringValue) and 
  dictKeyToString(dictionary, subsequentKey, keyStringValue) and 
  initialKey != subsequentKey and
  // Ensure initialKey appears before subsequentKey in control flow
  (
    // Case 1: Keys are in the same basic block with initialKey at a lower index
    exists(BasicBlock basicBlock, int initialIndex, int subsequentIndex |
      initialKey.getAFlowNode() = basicBlock.getNode(initialIndex) and
      subsequentKey.getAFlowNode() = basicBlock.getNode(subsequentIndex) and
      initialIndex < subsequentIndex
    )
    or
    // Case 2: The basic block containing initialKey strictly dominates the block containing subsequentKey
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location information
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
  subsequentKey, 
  "overwritten"