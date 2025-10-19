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
 * Converts dictionary keys to standardized string representations for comparison.
 * Handles numeric keys and string literals (Unicode and byte strings).
 */
predicate dictKeyToString(Dict targetDict, Expr keyExpr, string keyStr) {
  keyExpr = targetDict.getAKey() and
  (
    // Handle numeric keys by converting their value to string
    keyStr = keyExpr.(Num).getN()
    or
    // Handle string keys, including Unicode and byte string representations
    // Note: '�' indicates characters that cannot be properly represented
    not "�" = keyStr.charAt(_) and
    exists(StringLiteral stringLiteral | stringLiteral = keyExpr |
      keyStr = "u\"" + stringLiteral.getText() + "\"" and stringLiteral.isUnicode()
      or
      keyStr = "b\"" + stringLiteral.getText() + "\"" and not stringLiteral.isUnicode()
    )
  )
}

from Dict targetDict, Expr firstKey, Expr secondKey, string keyStr
where
  // Identify two distinct keys with identical string representations
  dictKeyToString(targetDict, firstKey, keyStr) and 
  dictKeyToString(targetDict, secondKey, keyStr) and 
  firstKey != secondKey and
  // Verify that firstKey appears before secondKey in the control flow
  (
    // Scenario 1: Keys reside in the same basic block with firstKey at a lower index
    exists(BasicBlock codeBlock, int firstIndex, int secondIndex |
      firstKey.getAFlowNode() = codeBlock.getNode(firstIndex) and
      secondKey.getAFlowNode() = codeBlock.getNode(secondIndex) and
      firstIndex < secondIndex
    )
    or
    // Scenario 2: The basic block containing firstKey strictly dominates the block containing secondKey
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location information
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"