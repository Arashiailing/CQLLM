/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals where earlier occurrences are overwritten by later ones.
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

// Converts dictionary keys to standardized string representations
// Handles numeric and string literals with proper type prefixes
predicate canonicalKeyRepresentation(Dict dictExpr, Expr keyValue, string normalizedKey) {
  keyValue = dictExpr.getAKey() and
  (
    // Numeric keys: direct value-to-string conversion
    normalizedKey = keyValue.(Num).getN()
    or
    // String literals: add type prefix and validate content
    not "�" = normalizedKey.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyValue and
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

// Identify duplicate keys where first occurrence gets overwritten
from Dict dictExpr, Expr firstKey, Expr secondKey
where
  // Both keys share identical canonical representation
  exists(string normalizedKey | 
    canonicalKeyRepresentation(dictExpr, firstKey, normalizedKey) and 
    canonicalKeyRepresentation(dictExpr, secondKey, normalizedKey) and 
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
// Generate alert showing which key overwrites the first occurrence
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"