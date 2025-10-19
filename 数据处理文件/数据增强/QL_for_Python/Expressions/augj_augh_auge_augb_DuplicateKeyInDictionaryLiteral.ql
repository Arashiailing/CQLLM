/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where earlier entries are overwritten
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
 * Normalizes dictionary keys to string representations for comparison.
 * Processes numeric values and string literals (Unicode/byte strings) while
 * excluding keys with unrepresentable characters (indicated by '�').
 */
predicate normalizeKey(Dict dictObj, Expr keyExpression, string normalizedKey) {
  keyExpression = dictObj.getAKey() and
  (
    // Handle numeric keys by direct value conversion
    normalizedKey = keyExpression.(Num).getN()
    or
    // Process string keys with normalized u"..." or b"..." format
    exists(StringLiteral stringLiteral | 
      stringLiteral = keyExpression and
      (
        (stringLiteral.isUnicode() and normalizedKey = "u\"" + stringLiteral.getText() + "\"")
        or
        (not stringLiteral.isUnicode() and normalizedKey = "b\"" + stringLiteral.getText() + "\"")
      ) and
      // Filter out keys containing unrepresentable characters
      not "�" = normalizedKey.charAt(_)
    )
  )
}

from Dict dictObj, Expr initialKey, Expr subsequentKey, string normalizedKey
where
  // Identify distinct keys with identical normalized representations
  normalizeKey(dictObj, initialKey, normalizedKey) and 
  normalizeKey(dictObj, subsequentKey, normalizedKey) and 
  initialKey != subsequentKey and
  // Ensure initialKey precedes subsequentKey in control flow
  (
    // Case 1: Keys in same basic block with initialKey at lower index
    exists(BasicBlock basicBlock, int initialIndex, int subsequentIndex |
      initialKey.getAFlowNode() = basicBlock.getNode(initialIndex) and
      subsequentKey.getAFlowNode() = basicBlock.getNode(subsequentIndex) and
      initialIndex < subsequentIndex
    )
    or
    // Case 2: initialKey's block strictly dominates subsequentKey's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location context
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is later $@.", 
  subsequentKey, 
  "overwritten"