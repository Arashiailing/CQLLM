/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where earlier definitions are silently overwritten by later ones.
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

// Normalizes dictionary keys into standardized string representations
// Handles numeric values and string literals with appropriate type prefixes
predicate getNormalizedKeyStr(Dict dictLiteral, Expr key, string normalizedStr) {
  key = dictLiteral.getAKey() and
  (
    // Numeric keys: direct conversion to string representation
    normalizedStr = key.(Num).getN()
    or
    // String literals: add type prefix and validate character integrity
    not "�" = normalizedStr.charAt(_) and
    exists(StringLiteral str | 
      str = key and
      (
        // Unicode strings: prefix with 'u'
        normalizedStr = "u\"" + str.getText() + "\"" and str.isUnicode()
        or
        // Byte strings: prefix with 'b'
        normalizedStr = "b\"" + str.getText() + "\"" and not str.isUnicode()
      )
    )
  )
}

// Locate duplicate keys where first occurrence is shadowed by subsequent definition
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Both keys resolve to identical normalized string representations
  exists(string normalizedKeyStr | 
    getNormalizedKeyStr(dictLiteral, firstKey, normalizedKeyStr) and 
    getNormalizedKeyStr(dictLiteral, secondKey, normalizedKeyStr) and 
    firstKey != secondKey
  ) and
  // Verify execution order relationship between keys
  (
    // Case 1: Keys reside in same basic block with firstKey appearing before secondKey
    exists(BasicBlock block, int firstPos, int secondPos |
      firstKey.getAFlowNode() = block.getNode(firstPos) and
      secondKey.getAFlowNode() = block.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: First key's basic block strictly dominates second key's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert showing which key overwrites the initial definition
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"