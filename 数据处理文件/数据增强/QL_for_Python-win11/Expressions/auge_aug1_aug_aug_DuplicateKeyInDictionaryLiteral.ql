/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where earlier occurrences are overwritten by later ones
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

// Converts dictionary keys to normalized string representations for comparison
// Handles numeric literals and string literals (including Unicode/byte prefixes)
predicate normalizedKeyMapping(Dict dictLiteral, Expr keyNode, string normalizedKeyStr) {
  keyNode = dictLiteral.getAKey() and
  (
    // Numeric keys: direct value conversion
    normalizedKeyStr = keyNode.(Num).getN()
    or
    // String keys: add appropriate prefixes based on type
    not "�" = normalizedKeyStr.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyNode and
      (
        // Unicode strings get 'u' prefix
        normalizedKeyStr = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings get 'b' prefix
        normalizedKeyStr = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Find duplicate keys in dictionary literals where first occurrence gets overwritten
from Dict dictLiteral, Expr initialKey, Expr subsequentKey
where
  // Keys must have identical normalized representations
  exists(string normalizedKeyStr | 
    normalizedKeyMapping(dictLiteral, initialKey, normalizedKeyStr) and 
    normalizedKeyMapping(dictLiteral, subsequentKey, normalizedKeyStr) and 
    initialKey != subsequentKey
  ) and
  // Verify position relationship between keys
  (
    // Case 1: Keys appear in same basic block with initialKey before subsequentKey
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
// Report alert showing which key overwrites the first occurrence
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       subsequentKey, 
       "overwritten"