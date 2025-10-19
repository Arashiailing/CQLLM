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

// Converts dictionary key expressions to canonical string representation for comparison
predicate canonicalKeyForm(Dict dictLiteral, Expr keyExpr, string canonicalKey) {
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys: use numeric value as canonical form
    canonicalKey = keyExpr.(Num).getN()
    or
    // String keys: handle Unicode and byte strings
    not "�" = canonicalKey.charAt(_) and
    exists(StringLiteral strLiteral | strLiteral = keyExpr |
      canonicalKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      canonicalKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

// Detects duplicate key pairs within the same dictionary literal
from Dict dictLiteral, Expr firstKey, Expr laterKey
where
  exists(string keyCanonicalForm | 
    canonicalKeyForm(dictLiteral, firstKey, keyCanonicalForm) and 
    canonicalKeyForm(dictLiteral, laterKey, keyCanonicalForm) and 
    firstKey != laterKey
  ) and
  (
    // Case 1: Keys appear in same basic block with firstKey preceding laterKey
    exists(BasicBlock sharedBlock, int firstPos, int laterPos |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstPos) and
      laterKey.getAFlowNode() = sharedBlock.getNode(laterPos) and
      firstPos < laterPos
    )
    or
    // Case 2: Basic block containing firstKey strictly dominates laterKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      laterKey.getAFlowNode().getBasicBlock()
    )
  )
// Report duplicate key issue with overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  laterKey, 
  "overwritten"