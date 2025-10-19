/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals where all but the last occurrence are overwritten
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
 * Converts dictionary keys to their string representation for comparison.
 * Handles numeric values and string literals (both Unicode and byte strings).
 */
predicate key_to_string(Dict dict, Expr keyExpr, string keyStr) {
  keyExpr = dict.getAKey() and
  (
    // Numeric keys: convert value to string
    keyStr = keyExpr.(Num).getN()
    or
    // String keys: handle Unicode/byte string representation
    // Special character handling: '�' represents unrepresentable characters
    not "�" = keyStr.charAt(_) and
    exists(StringLiteral strLiteral | strLiteral = keyExpr |
      keyStr = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      keyStr = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

from Dict dict, Expr firstKey, Expr secondKey
where
  // Find two distinct keys with identical string representations
  exists(string keyStr | 
    key_to_string(dict, firstKey, keyStr) and 
    key_to_string(dict, secondKey, keyStr) and 
    firstKey != secondKey
  ) and
  // Ensure firstKey appears before secondKey in control flow
  (
    // Case 1: Keys in same basic block with firstKey at lower index
    exists(BasicBlock block, int firstIndex, int secondIndex |
      firstKey.getAFlowNode() = block.getNode(firstIndex) and
      secondKey.getAFlowNode() = block.getNode(secondIndex) and
      firstIndex < secondIndex
    )
    or
    // Case 2: firstKey's block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location information
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"