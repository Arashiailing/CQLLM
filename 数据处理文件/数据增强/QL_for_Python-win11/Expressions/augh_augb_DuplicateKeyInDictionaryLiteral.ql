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
predicate key_to_string(Dict dict, Expr keyExpr, string keyRepresentation) {
  keyExpr = dict.getAKey() and
  (
    // Numeric keys: convert value to string
    keyRepresentation = keyExpr.(Num).getN()
    or
    // String keys: handle Unicode/byte string representation
    // Special character handling: '�' represents unrepresentable characters
    not "�" = keyRepresentation.charAt(_) and
    exists(StringLiteral strLiteral | strLiteral = keyExpr |
      keyRepresentation = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      keyRepresentation = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

from Dict dict, Expr overwrittenKey, Expr overwritingKey
where
  // Find two distinct keys with identical string representations
  exists(string keyRepresentation | 
    key_to_string(dict, overwrittenKey, keyRepresentation) and 
    key_to_string(dict, overwritingKey, keyRepresentation) and 
    overwrittenKey != overwritingKey
  ) and
  // Ensure overwrittenKey appears before overwritingKey in control flow
  (
    // Case 1: Keys in same basic block with overwrittenKey at lower index
    exists(BasicBlock block, int overwrittenIndex, int overwritingIndex |
      overwrittenKey.getAFlowNode() = block.getNode(overwrittenIndex) and
      overwritingKey.getAFlowNode() = block.getNode(overwritingIndex) and
      overwrittenIndex < overwritingIndex
    )
    or
    // Case 2: overwrittenKey's block strictly dominates overwritingKey's block
    overwrittenKey.getAFlowNode().getBasicBlock().strictlyDominates(
      overwritingKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location information
select overwrittenKey, 
  "Dictionary key " + repr(overwrittenKey) + " is subsequently $@.", 
  overwritingKey, 
  "overwritten"