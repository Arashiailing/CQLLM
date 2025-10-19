/**
 * @name Duplicate key in dictionary literal
 * @description Detects dictionary literals with duplicate keys where earlier occurrences are overwritten
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
 * Converts dictionary key expressions to normalized string representations
 * for comparison. Handles numeric keys and string literals (Unicode/byte strings).
 */
predicate canonicalKeyRepresentation(Dict dictionary, Expr key, string normalized) {
  key = dictionary.getAKey() and
  (
    // Numeric keys use their numeric value as normalized form
    normalized = key.(Num).getN()
    or
    // String literals get prefix and text normalization
    not "�" = normalized.charAt(_) and
    exists(StringLiteral strLit | strLit = key |
      normalized = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      normalized = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Find duplicate key pairs in dictionaries where first occurrence is overwritten
from Dict dictionary, Expr firstKey, Expr secondKey
where
  // Keys have identical normalized representations but are distinct expressions
  exists(string keyNorm | 
    canonicalKeyRepresentation(dictionary, firstKey, keyNorm) and 
    canonicalKeyRepresentation(dictionary, secondKey, keyNorm) and 
    firstKey != secondKey
  ) and
  (
    // Case 1: Keys appear in same basic block with firstKey preceding secondKey
    exists(BasicBlock block, int firstPos, int secondPos |
      firstKey.getAFlowNode() = block.getNode(firstPos) and
      secondKey.getAFlowNode() = block.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: firstKey's basic block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report duplicate key with overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"