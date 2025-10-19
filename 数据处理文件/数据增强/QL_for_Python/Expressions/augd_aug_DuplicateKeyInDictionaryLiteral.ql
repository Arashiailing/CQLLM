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
predicate normalize_key_representation(Dict dict, Expr keyExpression, string normalizedKeyString) {
  // Ensure keyExpression belongs to the dictionary
  keyExpression = dict.getAKey() and
  (
    // Handle numeric keys: direct numeric conversion
    normalizedKeyString = keyExpression.(Num).getN()
    or
    // Handle string keys (excluding special replacement characters)
    not "�" = normalizedKeyString.charAt(_) and
    // Process string literals with Unicode/byte prefix
    exists(StringLiteral strLiteral | strLiteral = keyExpression |
      normalizedKeyString = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      normalizedKeyString = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

// Identify duplicate key pairs in dictionaries
from Dict dict, Expr firstKeyExpr, Expr secondKeyExpr
where
  // Find keys with identical normalized representations
  exists(string normalizedKeyRepresentation | 
    normalize_key_representation(dict, firstKeyExpr, normalizedKeyRepresentation) and 
    normalize_key_representation(dict, secondKeyExpr, normalizedKeyRepresentation) and 
    firstKeyExpr != secondKeyExpr
  ) and
  (
    // Case 1: Keys appear in same basic block with firstKey preceding secondKey
    exists(BasicBlock commonBlock, int firstPosition, int secondPosition |
      firstKeyExpr.getAFlowNode() = commonBlock.getNode(firstPosition) and
      secondKeyExpr.getAFlowNode() = commonBlock.getNode(secondPosition) and
      firstPosition < secondPosition
    )
    or
    // Case 2: First key's basic block strictly dominates second key's block
    firstKeyExpr.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKeyExpr.getAFlowNode().getBasicBlock()
    )
  )
// Output warning message with duplicate key locations
select firstKeyExpr, 
  "Dictionary key " + repr(firstKeyExpr) + " is subsequently $@.", 
  secondKeyExpr, 
  "overwritten"