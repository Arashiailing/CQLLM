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

// Normalizes dictionary keys to a consistent string format
// Handles numeric literals and string literals (including byte and unicode strings)
predicate canonicalKeyRepresentation(Dict dictLiteral, Expr key, string canonicalForm) {
  key = dictLiteral.getAKey() and
  (
    // Numeric keys: direct value-to-string conversion
    canonicalForm = key.(Num).getN()
    or
    // String literals: add type prefix and validate content
    not "�" = canonicalForm.charAt(_) and
    exists(StringLiteral str | 
      str = key and
      (
        // Unicode strings: add 'u' prefix
        canonicalForm = "u\"" + str.getText() + "\"" and str.isUnicode()
        or
        // Byte strings: add 'b' prefix
        canonicalForm = "b\"" + str.getText() + "\"" and not str.isUnicode()
      )
    )
  )
}

// Find dictionary literals with duplicate keys
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Both keys share identical normalized representation
  exists(string canonicalForm | 
    canonicalKeyRepresentation(dictLiteral, firstKey, canonicalForm) and 
    canonicalKeyRepresentation(dictLiteral, secondKey, canonicalForm) and 
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

// Report the first occurrence of the duplicate key and indicate which later key overwrites it
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"