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

/**
 * Converts dictionary keys to standardized string representations for comparison.
 * Handles numeric keys (direct conversion) and string literals (with type prefixes).
 */
predicate normalizeDictKey(Dict dictLiteral, Expr keyNode, string keySignature) {
  keyNode = dictLiteral.getAKey() and
  (
    // For numeric keys: convert value directly to string
    keySignature = keyNode.(Num).getN()
    or
    // For string literals: add type-specific prefixes to distinguish between unicode and byte strings
    exists(StringLiteral strLiteral | 
      strLiteral = keyNode and
      (
        // Unicode strings: prefix with 'u"'
        keySignature = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: prefix with 'b"'
        keySignature = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Identify dictionary keys that overwrite earlier occurrences
from Dict dictLiteral, Expr firstKey, Expr secondKey, string keySignature
where
  // Both keys must have identical standardized representations
  normalizeDictKey(dictLiteral, firstKey, keySignature) and 
  normalizeDictKey(dictLiteral, secondKey, keySignature) and 
  firstKey != secondKey and
  // Ensure temporal ordering: first key appears before second key
  (
    // Case 1: Keys appear in same basic block with first occurrence earlier
    exists(BasicBlock basicBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = basicBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = basicBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: First occurrence's block strictly dominates later occurrence's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location of overwriting key
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"