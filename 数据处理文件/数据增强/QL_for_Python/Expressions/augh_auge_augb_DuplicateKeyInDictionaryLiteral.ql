/**
 * @name Duplicate key in dict literal
 * @description Detects dictionary literals with duplicate keys where earlier occurrences are overwritten
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
 * Converts dictionary keys to normalized string representations for comparison.
 * Handles numeric values and string literals (Unicode/byte strings) while
 * filtering out keys with unrepresentable characters (marked by '�').
 */
predicate keyToString(Dict dictLiteral, Expr keyExpr, string keyStr) {
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys: convert value directly to string
    keyStr = keyExpr.(Num).getN()
    or
    // String keys: normalize to u"..." or b"..." format
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpr and
      (
        (keyStr = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode())
        or
        (keyStr = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode())
      ) and
      // Exclude keys with unrepresentable characters
      not "�" = keyStr.charAt(_)
    )
  )
}

from Dict dictLiteral, Expr firstKey, Expr secondKey, string keyStr
where
  // Find distinct keys with identical string representations
  keyToString(dictLiteral, firstKey, keyStr) and 
  keyToString(dictLiteral, secondKey, keyStr) and 
  firstKey != secondKey and
  // Verify firstKey appears before secondKey in control flow
  (
    // Case 1: Keys in same basic block with firstKey at lower index
    exists(BasicBlock block, int firstIdx, int secondIdx |
      firstKey.getAFlowNode() = block.getNode(firstIdx) and
      secondKey.getAFlowNode() = block.getNode(secondIdx) and
      firstIdx < secondIdx
    )
    or
    // Case 2: firstKey's block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location context
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is later $@.", 
  secondKey, 
  "overwritten"