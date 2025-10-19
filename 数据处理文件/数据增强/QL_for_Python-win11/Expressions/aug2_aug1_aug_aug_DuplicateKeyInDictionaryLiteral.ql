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

// Identify duplicate keys where first occurrence gets overwritten
from Dict dictLiteral, Expr earlierKey, Expr laterKey
where
  // Both keys share identical canonical representation
  exists(string canonicalForm | 
    canonicalKeyRepresentation(dictLiteral, earlierKey, canonicalForm) and 
    canonicalKeyRepresentation(dictLiteral, laterKey, canonicalForm) and 
    earlierKey != laterKey
  ) and
  // Verify key ordering relationship
  (
    // Case 1: Keys in same basic block with earlierKey before laterKey
    exists(BasicBlock block, int earlierPos, int laterPos |
      earlierKey.getAFlowNode() = block.getNode(earlierPos) and
      laterKey.getAFlowNode() = block.getNode(laterPos) and
      earlierPos < laterPos
    )
    or
    // Case 2: Earlier key's block strictly dominates later key's block
    earlierKey.getAFlowNode().getBasicBlock().strictlyDominates(
      laterKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert showing which key overwrites the first occurrence
select earlierKey, 
       "Dictionary key " + repr(earlierKey) + " is subsequently $@.", 
       laterKey, 
       "overwritten"