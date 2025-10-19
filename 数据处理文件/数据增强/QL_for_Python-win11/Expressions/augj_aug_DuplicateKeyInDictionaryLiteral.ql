/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals where all but the last occurrence are lost
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

// Convert dictionary key expression to normalized string representation
predicate normalizeDictKey(Dict dict, Expr keyExpr, string keyRepresentation) {
  keyExpr = dict.getAKey() and
  (
    // Numeric keys: use numeric value directly
    keyRepresentation = keyExpr.(Num).getN()
    or
    // String keys with special character exclusion
    not "�" = keyRepresentation.charAt(_) and
    // Handle string literals (Unicode vs byte strings)
    exists(StringLiteral strLit | strLit = keyExpr |
      keyRepresentation = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      keyRepresentation = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Find duplicate key pairs in dictionaries
from Dict dict, Expr initialKey, Expr subsequentKey
where
  // Keys share normalized representation but are distinct expressions
  exists(string commonKeyRepr | 
    normalizeDictKey(dict, initialKey, commonKeyRepr) and 
    normalizeDictKey(dict, subsequentKey, commonKeyRepr) and 
    initialKey != subsequentKey
  ) and
  (
    // Case 1: Keys in same basic block with initialKey appearing first
    exists(BasicBlock block, int initialPos, int subsequentPos |
      initialKey.getAFlowNode() = block.getNode(initialPos) and
      subsequentKey.getAFlowNode() = block.getNode(subsequentPos) and
      initialPos < subsequentPos
    )
    or
    // Case 2: initialKey's block strictly dominates subsequentKey's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Output duplicate key warning with overwrite location
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
  subsequentKey, 
  "overwritten"