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

// Convert dictionary key expressions to normalized string representation
predicate getNormalizedKey(Dict dictExpr, Expr key, string normalizedForm) {
  // Verify key belongs to the dictionary
  key = dictExpr.getAKey() and
  (
    // Numeric keys: use numeric value as normalized form
    normalizedForm = key.(Num).getN()
    or
    // String keys: process literals without special characters
    exists(StringLiteral strLit | strLit = key |
      // Unicode strings: prefix with u"
      normalizedForm = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      // Byte strings: prefix with b"
      normalizedForm = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    ) and
    // Ensure normalized form contains no replacement characters
    not "�" = normalizedForm.charAt(_)
  )
}

// Identify duplicate keys within the same dictionary
from Dict dictExpr, Expr key1, Expr key2
where
  // Keys must have same normalized representation but be distinct expressions
  exists(string normalizedValue | 
    getNormalizedKey(dictExpr, key1, normalizedValue) and 
    getNormalizedKey(dictExpr, key2, normalizedValue) and 
    key1 != key2
  ) and
  // Position validation: first key must appear before second key
  (
    // Case 1: Keys in same basic block with first occurring earlier
    exists(BasicBlock sharedBlock, int pos1, int pos2 |
      key1.getAFlowNode() = sharedBlock.getNode(pos1) and
      key2.getAFlowNode() = sharedBlock.getNode(pos2) and
      pos1 < pos2
    )
    or
    // Case 2: First key's block strictly dominates second key's block
    key1.getAFlowNode().getBasicBlock().strictlyDominates(
      key2.getAFlowNode().getBasicBlock()
    )
  )
// Report duplicate key with overwrite location
select key1, 
  "Dictionary key " + repr(key1) + " is subsequently $@.", 
  key2, 
  "overwritten"