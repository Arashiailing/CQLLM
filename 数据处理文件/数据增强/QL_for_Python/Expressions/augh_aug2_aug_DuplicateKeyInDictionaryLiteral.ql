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

// Convert dictionary key expressions to canonical string representation
predicate getCanonicalKey(Dict dictLiteral, Expr keyExpr, string canonicalKey) {
  // Verify key belongs to the dictionary
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys: use numeric value as canonical form
    canonicalKey = keyExpr.(Num).getN()
    or
    // String keys: process literals without special characters
    not "�" = canonicalKey.charAt(_) and
    exists(StringLiteral strLit | strLit = keyExpr |
      // Unicode strings: prefix with u"
      canonicalKey = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      // Byte strings: prefix with b"
      canonicalKey = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate keys within the same dictionary
from Dict dictLiteral, Expr firstKey, Expr secondKey
where
  // Keys must have same canonical representation but be distinct expressions
  exists(string canonicalKeyStr | 
    getCanonicalKey(dictLiteral, firstKey, canonicalKeyStr) and 
    getCanonicalKey(dictLiteral, secondKey, canonicalKeyStr) and 
    firstKey != secondKey
  ) and
  // Position validation: first key must appear before second key
  (
    // Case 1: Keys in same basic block with first occurring earlier
    exists(BasicBlock sharedBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = sharedBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: First key's block strictly dominates second key's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report duplicate key with overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"