/**
 * @name Duplicate key in dict literal
 * @description Identifies duplicate keys in dictionary literals where all but the last occurrence are lost
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

// Predicate to convert dictionary key expressions to canonical string representations
predicate canonicalKeyForm(Dict dictLiteral, Expr keyExpr, string canonicalKeyStr) {
  // Verify key belongs to the dictionary
  keyExpr = dictLiteral.getAKey() and
  (
    // Handle numeric keys using their numeric value
    canonicalKeyStr = keyExpr.(Num).getN()
    or
    // Process string keys excluding those with special characters
    not "�" = canonicalKeyStr.charAt(_) and
    // Handle string literals with Unicode/byte distinction
    exists(StringLiteral strLit | strLit = keyExpr |
      canonicalKeyStr = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      canonicalKeyStr = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate key pairs within the same dictionary
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Keys must have identical canonical forms but be distinct expressions
  exists(string canonicalKeyStr | 
    canonicalKeyForm(dictLiteral, firstKey, canonicalKeyStr) and 
    canonicalKeyForm(dictLiteral, secondKey, canonicalKeyStr) and 
    firstKey != secondKey
  ) and
  (
    // Position relationship 1: Keys in same basic block with firstKey preceding secondKey
    exists(BasicBlock sharedBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = sharedBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Position relationship 2: firstKey's block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate warning highlighting the overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"