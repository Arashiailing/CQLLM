/**
 * @name Duplicate key in dict literal
 * @description Identifies duplicate keys in dictionary literals where all but the last occurrence are lost
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

// Predicate to normalize dictionary key expressions to canonical string representation
predicate normalizeKeyExpr(Dict dictLiteral, Expr keyExpr, string canonicalKey) {
  // Ensure the key expression belongs to the dictionary
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys: use numeric value as canonical representation
    canonicalKey = keyExpr.(Num).getN()
    or
    // String keys: process literals while excluding special characters
    exists(StringLiteral strLit | 
      strLit = keyExpr and
      // Skip keys containing replacement characters
      not "�" = canonicalKey.charAt(_) and
      // Differentiate between Unicode and byte strings
      (
        canonicalKey = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
        or
        canonicalKey = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
      )
    )
  )
}

// Identify duplicate key pairs within the same dictionary
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Both keys normalize to identical canonical representations
  exists(string canonicalKey | 
    normalizeKeyExpr(dictLiteral, firstKey, canonicalKey) and 
    normalizeKeyExpr(dictLiteral, secondKey, canonicalKey) and 
    firstKey != secondKey
  ) and
  (
    // Case 1: Keys appear sequentially in the same basic block
    exists(BasicBlock sharedBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = sharedBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: First key's basic block strictly dominates second key's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate warning highlighting the overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"