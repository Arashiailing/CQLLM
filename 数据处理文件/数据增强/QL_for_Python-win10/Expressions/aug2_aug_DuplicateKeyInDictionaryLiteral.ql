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

// Predicate to normalize dictionary key expressions to a canonical string representation
predicate normalizeKeyExpr(Dict dictionary, Expr keyExpression, string normalizedKey) {
  // Ensure the key expression belongs to the dictionary
  keyExpression = dictionary.getAKey() and
  (
    // For numeric keys, use the numeric value as the normalized representation
    normalizedKey = keyExpression.(Num).getN()
    or
    // Process string keys that do not contain special characters
    not "�" = normalizedKey.charAt(_) and
    // Handle string literals, differentiating between Unicode and byte strings
    exists(StringLiteral strLiteral | strLiteral = keyExpression |
      normalizedKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      normalizedKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

// Find pairs of duplicate keys within the same dictionary
from Dict dictionary, Expr initialKey, Expr subsequentKey
where
  // Both keys normalize to the same string representation but are different expressions
  exists(string normalizedKeyRepresentation | 
    normalizeKeyExpr(dictionary, initialKey, normalizedKeyRepresentation) and 
    normalizeKeyExpr(dictionary, subsequentKey, normalizedKeyRepresentation) and 
    initialKey != subsequentKey
  ) and
  (
    // Case 1: Both keys are in the same basic block with initialKey appearing before subsequentKey
    exists(BasicBlock commonBlock, int initialPosition, int subsequentPosition |
      initialKey.getAFlowNode() = commonBlock.getNode(initialPosition) and
      subsequentKey.getAFlowNode() = commonBlock.getNode(subsequentPosition) and
      initialPosition < subsequentPosition
    )
    or
    // Case 2: The basic block containing initialKey strictly dominates the block containing subsequentKey
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Output warning for duplicate keys, highlighting the overwrite location
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
  subsequentKey, 
  "overwritten"