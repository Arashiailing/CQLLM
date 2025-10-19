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

// Converts dictionary key expressions to canonical string representations for comparison
predicate normalizeKeyExpr(Dict targetDict, Expr keyExpr, string canonicalKeyStr) {
  // Ensure the key expression belongs to the target dictionary
  keyExpr = targetDict.getAKey() and
  (
    // Numeric keys: use raw numeric value as canonical representation
    canonicalKeyStr = keyExpr.(Num).getN()
    or
    // String keys: handle Unicode and byte strings with proper prefixes
    not "�" = canonicalKeyStr.charAt(_) and
    exists(StringLiteral strLit | strLit = keyExpr |
      canonicalKeyStr = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      canonicalKeyStr = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate keys within the same dictionary literal
from Dict targetDict, Expr firstKey, Expr secondKey
where
  // Both keys normalize to identical canonical representations but are distinct expressions
  exists(string canonicalKeyStr | 
    normalizeKeyExpr(targetDict, firstKey, canonicalKeyStr) and 
    normalizeKeyExpr(targetDict, secondKey, canonicalKeyStr) and 
    firstKey != secondKey
  ) and
  (
    // Position relationship 1: Keys appear in same basic block with firstKey preceding secondKey
    exists(BasicBlock sharedBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = sharedBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Position relationship 2: firstKey's basic block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert highlighting the key overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"