/**
 * @name Duplicate Key in Dictionary Literal
 * @description Identifies dictionary literals containing duplicate keys, 
 *              where the first occurrence's value is silently overwritten by subsequent occurrences.
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
predicate canonicalizeKeyExpression(Dict dictionaryLiteral, Expr keyExpression, string canonicalRepresentation) {
  // Ensure the key expression belongs to the target dictionary
  keyExpression = dictionaryLiteral.getAKey() and
  (
    // Process numeric keys using their numeric value
    canonicalRepresentation = keyExpression.(Num).getN()
    or
    // Handle string keys with type-specific formatting
    exists(StringLiteral stringLiteral | 
      stringLiteral = keyExpression and
      // Exclude keys containing replacement characters
      not "�" = canonicalRepresentation.charAt(_) and
      // Format based on string type (Unicode vs bytes)
      (
        canonicalRepresentation = "u\"" + stringLiteral.getText() + "\"" and stringLiteral.isUnicode()
        or
        canonicalRepresentation = "b\"" + stringLiteral.getText() + "\"" and not stringLiteral.isUnicode()
      )
    )
  )
}

// Identify duplicate key pairs in the same dictionary
from Dict targetDictionary, Expr firstKeyExpression, Expr secondKeyExpression
where
  // Keys must normalize to identical canonical representations
  exists(string canonicalKey | 
    canonicalizeKeyExpression(targetDictionary, firstKeyExpression, canonicalKey) and 
    canonicalizeKeyExpression(targetDictionary, secondKeyExpression, canonicalKey) and 
    firstKeyExpression != secondKeyExpression
  ) and
  (
    // Case 1: Keys appear sequentially in the same basic block
    exists(BasicBlock commonBasicBlock, int firstIndex, int secondIndex |
      firstKeyExpression.getAFlowNode() = commonBasicBlock.getNode(firstIndex) and
      secondKeyExpression.getAFlowNode() = commonBasicBlock.getNode(secondIndex) and
      firstIndex < secondIndex
    )
    or
    // Case 2: First key's block strictly dominates second key's block
    firstKeyExpression.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKeyExpression.getAFlowNode().getBasicBlock()
    )
  )
// Generate warning highlighting the overwrite location
select firstKeyExpression, 
  "Dictionary key " + repr(firstKeyExpression) + " is subsequently $@.", 
  secondKeyExpression, 
  "overwritten"