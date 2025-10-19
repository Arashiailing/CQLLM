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
predicate standardizeKeyRepresentation(Dict dictionaryLiteral, Expr keyExpr, string standardizedKeyForm) {
  keyExpr = dictionaryLiteral.getAKey() and
  (
    // Numeric keys: convert value directly to string
    standardizedKeyForm = keyExpr.(Num).getN()
    or
    // String literals: add type-specific prefixes
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpr and
      (
        // Unicode strings: prefix with 'u"'
        standardizedKeyForm = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: prefix with 'b"'
        standardizedKeyForm = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Find dictionary keys that overwrite earlier occurrences
from Dict dictionaryLiteral, Expr initialKey, Expr duplicateKey, string normalizedKey
where
  // Keys must have identical standardized representations
  standardizeKeyRepresentation(dictionaryLiteral, initialKey, normalizedKey) and 
  standardizeKeyRepresentation(dictionaryLiteral, duplicateKey, normalizedKey) and 
  initialKey != duplicateKey and
  // Verify temporal ordering of key occurrences
  (
    // Case 1: Keys appear in same basic block with first occurrence earlier
    exists(BasicBlock codeBlock, int initialPosition, int duplicatePosition |
      initialKey.getAFlowNode() = codeBlock.getNode(initialPosition) and
      duplicateKey.getAFlowNode() = codeBlock.getNode(duplicatePosition) and
      initialPosition < duplicatePosition
    )
    or
    // Case 2: First occurrence's block strictly dominates later occurrence's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location of overwriting key
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       duplicateKey, 
       "overwritten"