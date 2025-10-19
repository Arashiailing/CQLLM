/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals where all but the last occurrence are lost
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

// Convert dictionary key expressions to normalized string representations
predicate getNormalizedKey(Dict dict, Expr keyExpr, string normalizedKey) {
  // Ensure keyExpr belongs to the dictionary
  keyExpr = dict.getAKey() and
  (
    // Handle numeric keys: direct numeric conversion
    normalizedKey = keyExpr.(Num).getN()
    or
    // Handle string keys (excluding special replacement characters)
    not "�" = normalizedKey.charAt(_) and
    // Process string literals with Unicode/byte prefix
    exists(StringLiteral strLit | strLit = keyExpr |
      normalizedKey = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      normalizedKey = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate key pairs in dictionaries
from Dict dict, Expr key1, Expr key2
where
  // Find keys with identical normalized representations
  exists(string commonKey | 
    getNormalizedKey(dict, key1, commonKey) and 
    getNormalizedKey(dict, key2, commonKey) and 
    key1 != key2
  ) and
  (
    // Case 1: Keys appear in same basic block with key1 preceding key2
    exists(BasicBlock block, int pos1, int pos2 |
      key1.getAFlowNode() = block.getNode(pos1) and
      key2.getAFlowNode() = block.getNode(pos2) and
      pos1 < pos2
    )
    or
    // Case 2: key1's basic block strictly dominates key2's block
    key1.getAFlowNode().getBasicBlock().strictlyDominates(
      key2.getAFlowNode().getBasicBlock()
    )
  )
// Output warning message with duplicate key locations
select key1, 
  "Dictionary key " + repr(key1) + " is subsequently $@.", 
  key2, 
  "overwritten"