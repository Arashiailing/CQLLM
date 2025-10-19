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

// Predicate to convert dictionary key expressions to canonical string representations
predicate normalizeKeyExpr(Dict dictExpr, Expr keyNode, string normalizedKey) {
  // Ensure key belongs to the specified dictionary
  keyNode = dictExpr.getAKey() and
  (
    // Numeric keys: use numeric value as canonical form
    normalizedKey = keyNode.(Num).getN()
    or
    // String keys: handle literals while excluding special characters
    exists(StringLiteral strLit | 
      strLit = keyNode and
      // Skip keys containing replacement characters
      not "�" = normalizedKey.charAt(_) and
      // Distinguish Unicode and byte string representations
      (
        normalizedKey = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
        or
        normalizedKey = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
      )
    )
  )
}

// Identify duplicate key pairs within dictionary literals
from Dict dictExpr, Expr originalKey, Expr duplicateKey
where
  // Both keys normalize to identical canonical representations
  exists(string normalizedKey | 
    normalizeKeyExpr(dictExpr, originalKey, normalizedKey) and 
    normalizeKeyExpr(dictExpr, duplicateKey, normalizedKey) and 
    originalKey != duplicateKey
  ) and
  (
    // Case 1: Keys appear sequentially in the same basic block
    exists(BasicBlock commonBlock, int originalPos, int duplicatePos |
      originalKey.getAFlowNode() = commonBlock.getNode(originalPos) and
      duplicateKey.getAFlowNode() = commonBlock.getNode(duplicatePos) and
      originalPos < duplicatePos
    )
    or
    // Case 2: Original key's block strictly dominates duplicate key's block
    originalKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate warning highlighting the overwrite location
select originalKey, 
  "Dictionary key " + repr(originalKey) + " is subsequently $@.", 
  duplicateKey, 
  "overwritten"