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

// Maps dictionary keys to their canonical string representations
predicate keyStringRepresentation(Dict dictionary, Expr keyExpression, string keyString) {
  keyExpression = dictionary.getAKey() and
  (
    // Numeric keys: directly convert value to string
    keyString = keyExpression.(Num).getN()
    or
    // String literal keys: handle with proper prefix markers
    not "�" = keyString.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpression and
      (
        // Unicode string literal prefix
        keyString = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte string literal prefix
        keyString = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Identify duplicate keys where initial occurrence gets overwritten
from Dict dictionary, Expr initialKey, Expr subsequentKey
where
  // Verify keys have identical string representations
  exists(string canonicalKeyString | 
    keyStringRepresentation(dictionary, initialKey, canonicalKeyString) and 
    keyStringRepresentation(dictionary, subsequentKey, canonicalKeyString) and 
    initialKey != subsequentKey
  ) and
  (
    // Case 1: Keys appear in same basic block with initialKey before subsequentKey
    exists(BasicBlock containingBlock, int initialIndex, int subsequentIndex |
      initialKey.getAFlowNode() = containingBlock.getNode(initialIndex) and
      subsequentKey.getAFlowNode() = containingBlock.getNode(subsequentIndex) and
      initialIndex < subsequentIndex
    )
    or
    // Case 2: Initial key's basic block strictly dominates subsequent key's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert indicating which key overwrites the initial occurrence
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       subsequentKey, 
       "overwritten"