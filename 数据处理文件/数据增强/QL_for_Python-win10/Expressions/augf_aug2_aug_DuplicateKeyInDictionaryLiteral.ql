/**
 * @name Duplicate key in dict literal
 * @description Detects dictionary literals containing duplicate keys where earlier values are overwritten
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

// Converts dictionary key expressions to canonical string representations for comparison
predicate canonicalKeyForm(Dict dictLiteral, Expr keyExpr, string canonicalKey) {
  // Verify key belongs to the dictionary
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys use their numeric value as canonical form
    canonicalKey = keyExpr.(Num).getN()
    or
    // String keys without special characters
    not "�" = canonicalKey.charAt(_) and
    // Handle string literals with Unicode/byte prefixes
    exists(StringLiteral strLit | strLit = keyExpr |
      canonicalKey = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      canonicalKey = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate keys in dictionary literals
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Keys have identical canonical forms but are different expressions
  exists(string keySignature | 
    canonicalKeyForm(dictLiteral, firstKey, keySignature) and 
    canonicalKeyForm(dictLiteral, secondKey, keySignature) and 
    firstKey != secondKey
  ) and
  (
    // Case 1: Keys in same basic block with firstKey appearing earlier
    exists(BasicBlock sharedBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = sharedBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: firstKey's basic block strictly dominates secondKey's
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report duplicate key with overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"