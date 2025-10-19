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

// Helper predicate to extract string representation of dictionary keys
predicate getDictKeyRepresentation(Dict dictLiteral, Expr key, string keyString) {
  key = dictLiteral.getAKey() and
  (
    // Handle numeric keys
    keyString = key.(Num).getN()
    or
    // Handle string keys (avoid special character collision)
    not "�" = keyString.charAt(_) and
    exists(StringLiteral strLiteral | strLiteral = key |
      keyString = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      keyString = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

// Identify duplicate dictionary keys with position constraints
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  exists(string keyString | 
    getDictKeyRepresentation(dictLiteral, firstKey, keyString) and
    getDictKeyRepresentation(dictLiteral, secondKey, keyString) and
    firstKey != secondKey
  ) and
  (
    // Keys appear in same basic block with firstKey before secondKey
    exists(BasicBlock block, int pos1, int pos2 |
      firstKey.getAFlowNode() = block.getNode(pos1) and
      secondKey.getAFlowNode() = block.getNode(pos2) and
      pos1 < pos2
    )
    or
    // firstKey's basic block strictly dominates secondKey's
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report duplicate key with overwrite context
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"