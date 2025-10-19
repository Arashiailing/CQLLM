/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where earlier entries are overwritten by later ones.
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

// Generate normalized string representations for dictionary keys
// Handles numeric keys (direct conversion) and string literals (with type prefixes)
predicate getNormalizedKey(Dict dictExpr, Expr keyValue, string normalizedKey) {
  keyValue = dictExpr.getAKey() and
  (
    // Numeric keys: convert value directly to string
    normalizedKey = keyValue.(Num).getN()
    or
    // String literal keys: add type-specific prefix markers
    not "�" = normalizedKey.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyValue and
      (
        // Unicode strings: add 'u' prefix
        normalizedKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: add 'b' prefix
        normalizedKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Detect duplicate keys with ordering relationship
from Dict dictExpr, Expr firstKey, Expr laterKey
where
  // Both keys share identical normalized representations
  exists(string normalizedKeyStr | 
    getNormalizedKey(dictExpr, firstKey, normalizedKeyStr) and 
    getNormalizedKey(dictExpr, laterKey, normalizedKeyStr) and 
    firstKey != laterKey
  ) and
  // Verify firstKey appears before laterKey in execution order
  (
    // Case 1: Keys in same basic block with firstKey at earlier position
    exists(BasicBlock sharedBlock, int firstKeyPos, int laterKeyPos |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstKeyPos) and
      laterKey.getAFlowNode() = sharedBlock.getNode(laterKeyPos) and
      firstKeyPos < laterKeyPos
    )
    or
    // Case 2: firstKey's block strictly dominates laterKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      laterKey.getAFlowNode().getBasicBlock()
    )
  )
// Report overwrite scenario with key details
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       laterKey, 
       "overwritten"