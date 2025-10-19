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

// Convert dictionary keys to normalized string representations for comparison
// Handles numeric keys (direct value conversion) and string literals (with prefix markers)
predicate normalizedKeyRepresentation(Dict dictLiteral, Expr keyNode, string normalizedKeyStr) {
  keyNode = dictLiteral.getAKey() and
  (
    // Numeric keys: convert value directly to string
    normalizedKeyStr = keyNode.(Num).getN()
    or
    // String literal keys: add appropriate prefix markers
    not "�" = normalizedKeyStr.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyNode and
      (
        // Unicode strings: add 'u' prefix
        normalizedKeyStr = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: add 'b' prefix
        normalizedKeyStr = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Find duplicate keys where the first occurrence gets overwritten
from Dict dictLiteral, Expr initialKey, Expr subsequentKey
where
  // Both keys must have identical normalized representations
  exists(string keyNormStr | 
    normalizedKeyRepresentation(dictLiteral, initialKey, keyNormStr) and 
    normalizedKeyRepresentation(dictLiteral, subsequentKey, keyNormStr) and 
    initialKey != subsequentKey
  ) and
  // Verify ordering relationship between keys
  (
    // Case 1: Keys in same basic block with initialKey appearing first
    exists(BasicBlock commonBlock, int initialKeyIndex, int subsequentKeyIndex |
      initialKey.getAFlowNode() = commonBlock.getNode(initialKeyIndex) and
      subsequentKey.getAFlowNode() = commonBlock.getNode(subsequentKeyIndex) and
      initialKeyIndex < subsequentKeyIndex
    )
    or
    // Case 2: initialKey's block strictly dominates subsequentKey's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert showing which key overwrites the first occurrence
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       subsequentKey, 
       "overwritten"