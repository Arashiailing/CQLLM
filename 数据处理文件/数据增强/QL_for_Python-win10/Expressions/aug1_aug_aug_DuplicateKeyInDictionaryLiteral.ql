/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals. Earlier occurrences are overwritten by later ones.
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

// Maps dictionary keys to their canonical string representation
// This predicate handles different types of keys (numeric and string literals)
// and converts them to a standardized string format for comparison
predicate canonicalKeyRepresentation(Dict targetDict, Expr keyExpr, string canonicalKeyStr) {
  keyExpr = targetDict.getAKey() and
  (
    // Handle numeric keys by directly converting the value to string
    canonicalKeyStr = keyExpr.(Num).getN()
    or
    // Handle string literal keys with proper prefix markers
    not "�" = canonicalKeyStr.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpr and
      (
        // Add Unicode string literal prefix for Unicode strings
        canonicalKeyStr = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Add byte string literal prefix for non-Unicode strings
        canonicalKeyStr = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Identify duplicate keys in dictionary literals where the first occurrence gets overwritten
from Dict targetDict, Expr firstKey, Expr duplicateKey
where
  // Both keys must have the same canonical string representation
  exists(string keyCanonicalStr | 
    canonicalKeyRepresentation(targetDict, firstKey, keyCanonicalStr) and 
    canonicalKeyRepresentation(targetDict, duplicateKey, keyCanonicalStr) and 
    firstKey != duplicateKey
  ) and
  // Check the ordering relationship between the keys
  (
    // Case 1: Keys appear in the same basic block with firstKey before duplicateKey
    exists(BasicBlock sharedBlock, int firstKeyIndex, int duplicateKeyIndex |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstKeyIndex) and
      duplicateKey.getAFlowNode() = sharedBlock.getNode(duplicateKeyIndex) and
      firstKeyIndex < duplicateKeyIndex
    )
    or
    // Case 2: The basic block containing firstKey strictly dominates the block containing duplicateKey
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert indicating which key overwrites the first occurrence
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       duplicateKey, 
       "overwritten"