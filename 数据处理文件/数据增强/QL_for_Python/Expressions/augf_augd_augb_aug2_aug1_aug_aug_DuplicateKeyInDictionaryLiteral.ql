/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys, where earlier key-value pairs are silently overwritten by later ones.
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

// Normalize dictionary keys to consistent string representation
// Handles numeric literals and string literals (including byte/unicode strings)
predicate normalizeKeyRepresentation(Dict dictLiteral, Expr keyExpr, string normalizedKey) {
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys: direct value-to-string conversion
    normalizedKey = keyExpr.(Num).getN()
    or
    // String literals: add type prefix and validate content
    not "�" = normalizedKey.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpr and
      (
        // Unicode strings: add 'u' prefix
        normalizedKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: add 'b' prefix
        normalizedKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Identify dictionaries with duplicate keys and their positional relationships
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Both keys share identical normalized representation
  exists(string normalizedKey | 
    normalizeKeyRepresentation(dictLiteral, firstKey, normalizedKey) and 
    normalizeKeyRepresentation(dictLiteral, secondKey, normalizedKey) and 
    firstKey != secondKey
  ) and
  // Verify key ordering relationship
  (
    // Case 1: Keys in same basic block with firstKey before secondKey
    exists(BasicBlock block, int firstPos, int secondPos |
      firstKey.getAFlowNode() = block.getNode(firstPos) and
      secondKey.getAFlowNode() = block.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: First key's block strictly dominates second key's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )

// Report the first occurrence of duplicate key and indicate its overwriter
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"