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
 * Converts dictionary keys to their normalized string representation for comparison.
 * Handles numeric values and string literals (both Unicode and byte strings).
 */
predicate dictKeyToString(Dict dict, Expr keyExpr, string normalizedKey) {
  keyExpr = dict.getAKey() and
  (
    // Numeric keys: convert value to string
    normalizedKey = keyExpr.(Num).getN()
    or
    // String keys: handle Unicode/byte string representation
    // Special character handling: '�' represents unrepresentable characters
    not "�" = normalizedKey.charAt(_) and
    exists(StringLiteral strLiteral | strLiteral = keyExpr |
      normalizedKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      normalizedKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

from Dict dict, Expr overwrittenKey, Expr retainedKey
where
  // Find distinct keys with identical normalized representations
  exists(string keyRepresentation | 
    dictKeyToString(dict, overwrittenKey, keyRepresentation) and 
    dictKeyToString(dict, retainedKey, keyRepresentation) and 
    overwrittenKey != retainedKey
  ) and
  // Verify position relationship ensuring overwrittenKey appears before retainedKey
  (
    // Case 1: Keys in same basic block with overwrittenKey at lower index
    exists(BasicBlock block, int overwrittenIdx, int retainedIdx |
      overwrittenKey.getAFlowNode() = block.getNode(overwrittenIdx) and
      retainedKey.getAFlowNode() = block.getNode(retainedIdx) and
      overwrittenIdx < retainedIdx
    )
    or
    // Case 2: overwrittenKey's block strictly dominates retainedKey's block
    overwrittenKey.getAFlowNode().getBasicBlock().strictlyDominates(
      retainedKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location information
select overwrittenKey, 
  "Dictionary key " + repr(overwrittenKey) + " is subsequently $@.", 
  retainedKey, 
  "overwritten"