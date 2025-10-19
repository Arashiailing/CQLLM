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

// Converts dictionary keys to standardized string representations for comparison
// Handles numeric keys (direct conversion) and string literals (with type prefixes)
predicate canonicalKeyRepresentation(Dict dict, Expr key, string canonicalForm) {
  key = dict.getAKey() and
  (
    // Numeric keys: convert value directly to string
    canonicalForm = key.(Num).getN()
    or
    // String literals: add type-specific prefixes
    exists(StringLiteral strLiteral | 
      strLiteral = key and
      (
        // Unicode strings: prefix with 'u"'
        canonicalForm = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: prefix with 'b"'
        canonicalForm = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Find dictionary keys that overwrite earlier occurrences
from Dict dict, Expr firstOccurrence, Expr laterOccurrence
where
  // Keys must have identical canonical representations
  exists(string canonicalKey | 
    canonicalKeyRepresentation(dict, firstOccurrence, canonicalKey) and 
    canonicalKeyRepresentation(dict, laterOccurrence, canonicalKey) and 
    firstOccurrence != laterOccurrence
  ) and
  // Verify temporal ordering of key occurrences
  (
    // Case 1: Keys appear in same basic block with first occurrence earlier
    exists(BasicBlock block, int firstIndex, int laterIndex |
      firstOccurrence.getAFlowNode() = block.getNode(firstIndex) and
      laterOccurrence.getAFlowNode() = block.getNode(laterIndex) and
      firstIndex < laterIndex
    )
    or
    // Case 2: First occurrence's block strictly dominates later occurrence's block
    firstOccurrence.getAFlowNode().getBasicBlock().strictlyDominates(
      laterOccurrence.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location of overwriting key
select firstOccurrence, 
       "Dictionary key " + repr(firstOccurrence) + " is subsequently $@.", 
       laterOccurrence, 
       "overwritten"