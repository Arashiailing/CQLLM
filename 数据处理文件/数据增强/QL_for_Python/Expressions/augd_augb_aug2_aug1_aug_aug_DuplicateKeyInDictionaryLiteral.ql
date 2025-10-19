/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys, where earlier key-value pairs are silently overwritten by later ones.
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

// Normalizes dictionary keys to a consistent string representation
// Handles numeric literals and string literals (including byte and unicode strings)
predicate getNormalizedKeyString(Dict dictExpr, Expr keyValue, string normalizedKeyStr) {
  keyValue = dictExpr.getAKey() and
  (
    // Numeric keys: direct value-to-string conversion
    normalizedKeyStr = keyValue.(Num).getN()
    or
    // String literals: add type prefix and validate content
    not "�" = normalizedKeyStr.charAt(_) and
    exists(StringLiteral strLiteral | 
      strLiteral = keyValue and
      (
        // Unicode strings: add 'u' prefix
        normalizedKeyStr = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: add 'b' prefix
        normalizedKeyStr = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Find dictionary literals with duplicate keys
from Dict dictExpr, Expr initialKey, Expr subsequentKey
where
  // Both keys share identical normalized representation
  exists(string normalizedKeyStr | 
    getNormalizedKeyString(dictExpr, initialKey, normalizedKeyStr) and 
    getNormalizedKeyString(dictExpr, subsequentKey, normalizedKeyStr) and 
    initialKey != subsequentKey
  ) and
  // Verify key ordering relationship
  (
    // Case 1: Keys in same basic block with initialKey before subsequentKey
    exists(BasicBlock basicBlock, int initialPos, int subsequentPos |
      initialKey.getAFlowNode() = basicBlock.getNode(initialPos) and
      subsequentKey.getAFlowNode() = basicBlock.getNode(subsequentPos) and
      initialPos < subsequentPos
    )
    or
    // Case 2: Initial key's block strictly dominates subsequent key's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )

// Report the first occurrence of the duplicate key and indicate which later key overwrites it
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       subsequentKey, 
       "overwritten"