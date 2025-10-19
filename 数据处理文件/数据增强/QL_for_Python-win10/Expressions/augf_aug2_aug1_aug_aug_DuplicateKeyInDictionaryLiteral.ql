/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where earlier entries are overwritten by later ones.
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

// Converts dictionary keys to normalized string representations
// Handles numeric literals and string literals with appropriate type prefixes
predicate canonicalKeyRepresentation(Dict dictLiteral, Expr keyExpr, string normalizedKeyStr) {
  keyExpr = dictLiteral.getAKey() and
  not "�" = normalizedKeyStr.charAt(_) and
  (
    // Numeric keys: direct value-to-string conversion
    normalizedKeyStr = keyExpr.(Num).getN()
    or
    // String literals: add type prefix and validate content
    exists(StringLiteral stringLiteral | 
      stringLiteral = keyExpr and
      (
        // Unicode strings: add 'u' prefix
        normalizedKeyStr = "u\"" + stringLiteral.getText() + "\"" and stringLiteral.isUnicode()
        or
        // Byte strings: add 'b' prefix
        normalizedKeyStr = "b\"" + stringLiteral.getText() + "\"" and not stringLiteral.isUnicode()
      )
    )
  )
}

// Identify duplicate keys where first occurrence gets overwritten by later one
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Both keys share identical normalized representation
  exists(string normalizedKeyStr | 
    canonicalKeyRepresentation(dictLiteral, firstKey, normalizedKeyStr) and 
    canonicalKeyRepresentation(dictLiteral, secondKey, normalizedKeyStr) and 
    firstKey != secondKey
  ) and
  // Verify key ordering relationship
  (
    // Case 1: Keys in same basic block with firstKey before secondKey
    exists(BasicBlock basicBlock, int firstPosition, int secondPosition |
      firstKey.getAFlowNode() = basicBlock.getNode(firstPosition) and
      secondKey.getAFlowNode() = basicBlock.getNode(secondPosition) and
      firstPosition < secondPosition
    )
    or
    // Case 2: First key's block strictly dominates second key's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert showing which key overwrites the first occurrence
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"