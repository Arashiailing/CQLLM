/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where initial values are silently replaced by subsequent ones.
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

// Normalize dictionary keys to string representations for comparison
// Handles numeric values (direct conversion) and string literals (with type prefixes)
predicate keyNormalization(Dict dictionary, Expr keyExpr, string normalizedKey) {
  keyExpr = dictionary.getAKey() and
  (
    // Convert numeric keys to string representation
    normalizedKey = keyExpr.(Num).getN()
    or
    // Process string literals with appropriate type prefixes
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpr and
      (
        // Unicode strings receive 'u"' prefix
        normalizedKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings receive 'b"' prefix
        normalizedKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Helper predicate to verify temporal ordering of keys in code flow
predicate temporalKeyOrder(Expr firstKey, Expr secondKey) {
  // Case 1: Keys exist in same basic block with first appearing earlier
  exists(BasicBlock basicBlock, int firstPos, int secondPos |
    firstKey.getAFlowNode() = basicBlock.getNode(firstPos) and
    secondKey.getAFlowNode() = basicBlock.getNode(secondPos) and
    firstPos < secondPos
  )
  or
  // Case 2: First key's basic block strictly dominates second key's basic block
  firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
    secondKey.getAFlowNode().getBasicBlock()
  )
}

// Identify dictionary literals containing duplicate keys
from Dict dictionary, Expr firstKey, Expr secondKey
where
  // Keys must have identical normalized representations but be different expressions
  exists(string keySignature | 
    keyNormalization(dictionary, firstKey, keySignature) and 
    keyNormalization(dictionary, secondKey, keySignature) and 
    firstKey != secondKey
  ) and
  // Verify proper temporal ordering of key occurrences
  temporalKeyOrder(firstKey, secondKey)
// Report the overwritten key with location of the overwriting duplicate
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"