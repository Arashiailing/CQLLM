/**
 * @name Duplicate key in dict literal
 * @description Detects dictionary literals containing duplicate keys where earlier occurrences are silently overwritten by later ones
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

// Generates canonical string representations for dictionary keys
predicate canonicalKeyStr(Dict dictLiteral, Expr keyExpr, string strRepr) {
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys: direct value conversion
    strRepr = keyExpr.(Num).getN()
    or
    // String literal keys: preserve prefix markers
    not "�" = strRepr.charAt(_) and
    exists(StringLiteral strLit | 
      strLit = keyExpr and
      (
        // Unicode string prefix handling
        strRepr = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
        or
        // Byte string prefix handling
        strRepr = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
      )
    )
  )
}

// Identify duplicate keys where initial occurrence gets overwritten
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Verify keys have identical canonical representations
  exists(string canonicalStr | 
    canonicalKeyStr(dictLiteral, firstKey, canonicalStr) and 
    canonicalKeyStr(dictLiteral, secondKey, canonicalStr) and 
    firstKey != secondKey
  ) and
  (
    // Case 1: Keys in same basic block with ordering constraint
    exists(BasicBlock commonBlock, int firstIdx, int secondIdx |
      firstKey.getAFlowNode() = commonBlock.getNode(firstIdx) and
      secondKey.getAFlowNode() = commonBlock.getNode(secondIdx) and
      firstIdx < secondIdx
    )
    or
    // Case 2: Initial key's block dominates subsequent key's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert showing which key overwrites the initial occurrence
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"