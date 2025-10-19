/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals where earlier values are overwritten
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

// Converts dictionary key expressions to canonical string representations
predicate normalizeKeyExpr(Dict dictLit, Expr keyNode, string canonicalForm) {
  // Verify key belongs to target dictionary
  keyNode = dictLit.getAKey() and
  (
    // Handle numeric keys using their numeric value
    canonicalForm = keyNode.(Num).getN()
    or
    // Process string keys with type-specific formatting
    exists(StringLiteral strLit | 
      strLit = keyNode and
      // Exclude keys with replacement characters
      not "�" = canonicalForm.charAt(_) and
      // Format based on string type (Unicode vs bytes)
      (
        canonicalForm = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
        or
        canonicalForm = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
      )
    )
  )
}

// Identify duplicate key pairs in the same dictionary
from Dict targetDict, Expr firstKeyNode, Expr secondKeyNode
where
  // Keys must normalize to identical canonical representations
  exists(string keyCanonical | 
    normalizeKeyExpr(targetDict, firstKeyNode, keyCanonical) and 
    normalizeKeyExpr(targetDict, secondKeyNode, keyCanonical) and 
    firstKeyNode != secondKeyNode
  ) and
  (
    // Case 1: Keys appear sequentially in same basic block
    exists(BasicBlock sharedBlock, int firstIdx, int secondIdx |
      firstKeyNode.getAFlowNode() = sharedBlock.getNode(firstIdx) and
      secondKeyNode.getAFlowNode() = sharedBlock.getNode(secondIdx) and
      firstIdx < secondIdx
    )
    or
    // Case 2: First key's block strictly dominates second key's block
    firstKeyNode.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKeyNode.getAFlowNode().getBasicBlock()
    )
  )
// Generate warning highlighting overwrite location
select firstKeyNode, 
  "Dictionary key " + repr(firstKeyNode) + " is subsequently $@.", 
  secondKeyNode, 
  "overwritten"