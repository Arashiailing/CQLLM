/**
 * @name Duplicate key in dictionary literal
 * @description Identifies dictionary literals containing duplicate keys that result in overwriting previous values
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
 * Converts dictionary key expressions into standardized string representations
 * to facilitate comparison. Handles numeric values and string literals
 * (including both Unicode and byte strings).
 */
predicate standardizedKeyRepresentation(Dict dictionary, Expr keyExpression, string normalizedValue) {
  keyExpression = dictionary.getAKey() and
  (
    // Numeric keys are represented by their numeric value
    normalizedValue = keyExpression.(Num).getN()
    or
    // String literals are normalized with appropriate prefix and content
    not "�" = normalizedValue.charAt(_) and
    exists(StringLiteral stringLiteral | stringLiteral = keyExpression |
      normalizedValue = "u\"" + stringLiteral.getText() + "\"" and stringLiteral.isUnicode()
      or
      normalizedValue = "b\"" + stringLiteral.getText() + "\"" and not stringLiteral.isUnicode()
    )
  )
}

// Helper predicate to check if two keys are duplicates with proper ordering
predicate keysAreDuplicates(Dict targetDictionary, Expr firstKey, Expr secondKey) {
  exists(string keySignature |
    standardizedKeyRepresentation(targetDictionary, firstKey, keySignature) and 
    standardizedKeyRepresentation(targetDictionary, secondKey, keySignature) and 
    firstKey != secondKey
  )
}

// Helper predicate to verify position relationship between keys
predicate keyAppearsBefore(Expr firstKey, Expr secondKey) {
  // Case 1: Keys in same basic block with firstKey appearing before secondKey
  exists(BasicBlock blockContainer, int firstPosition, int secondPosition |
    firstKey.getAFlowNode() = blockContainer.getNode(firstPosition) and
    secondKey.getAFlowNode() = blockContainer.getNode(secondPosition) and
    firstPosition < secondPosition
  )
  or
  // Case 2: Basic block of firstKey strictly dominates block of secondKey
  firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
    secondKey.getAFlowNode().getBasicBlock()
  )
}

// Main query to identify dictionaries with duplicate keys
from Dict targetDictionary, Expr firstKey, Expr secondKey
where
  keysAreDuplicates(targetDictionary, firstKey, secondKey) and
  keyAppearsBefore(firstKey, secondKey)
// Report the duplicate key issue with location of the overwrite
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"