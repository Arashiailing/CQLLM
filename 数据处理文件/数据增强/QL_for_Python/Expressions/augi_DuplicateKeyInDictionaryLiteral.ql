/**
 * @name Duplicate key in dict literal
 * @description Detects dictionary literals containing duplicate keys. Earlier occurrences are overwritten by later ones.
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

// Predicate to determine the string representation of dictionary keys
// for comparison purposes. Handles numeric and string literals.
predicate get_key_representation(Dict dictExpr, Expr keyExpr, string keyStr) {
  // Verify keyExpr belongs to the dictionary dictExpr
  keyExpr = dictExpr.getAKey() and
  (
    // For numeric keys, convert value to string representation
    keyStr = keyExpr.(Num).getN()
    or
    // Special handling for non-printable characters using replacement character
    not "�" = keyStr.charAt(_) and
    // Process string literals with appropriate prefixes
    exists(StringLiteral strLit | strLit = keyExpr |
      keyStr = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      keyStr = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate keys in dictionary literals
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Find keys with identical string representations
  exists(string keyRep | 
    get_key_representation(dictLiteral, firstKey, keyRep) and 
    get_key_representation(dictLiteral, secondKey, keyRep) and 
    firstKey != secondKey
  ) and
  // Ensure firstKey appears before secondKey in execution order
  (
    // Case 1: Keys appear in same basic block with firstKey at lower index
    exists(BasicBlock block, int pos1, int pos2 |
      firstKey.getAFlowNode() = block.getNode(pos1) and
      secondKey.getAFlowNode() = block.getNode(pos2) and
      pos1 < pos2
    )
    or
    // Case 2: firstKey's basic block strictly dominates secondKey's
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the first occurrence being overwritten by the second
select firstKey, "Dictionary key " + repr(firstKey) + " is subsequently $@.", secondKey, "overwritten"