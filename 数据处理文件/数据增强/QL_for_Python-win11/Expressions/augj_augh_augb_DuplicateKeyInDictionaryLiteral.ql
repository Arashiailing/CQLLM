/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals where all but the last occurrence are overwritten
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

/**
 * Converts dictionary keys to normalized string representations for comparison.
 * Handles numeric values and string literals (Unicode/byte strings).
 */
predicate key_to_string(Dict dict, Expr keyExpr, string normalizedKey) {
  keyExpr = dict.getAKey() and
  (
    // Numeric keys: direct value conversion
    normalizedKey = keyExpr.(Num).getN()
    or
    // String keys: handle Unicode/byte string representation
    // Special character '�' indicates unrepresentable characters
    not "�" = normalizedKey.charAt(_) and
    exists(StringLiteral strLiteral | strLiteral = keyExpr |
      normalizedKey = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      normalizedKey = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

from Dict dictObj, Expr firstKey, Expr secondKey
where
  // Identify distinct keys with identical normalized representations
  exists(string normalizedKey | 
    key_to_string(dictObj, firstKey, normalizedKey) and 
    key_to_string(dictObj, secondKey, normalizedKey) and 
    firstKey != secondKey
  ) and
  // Verify firstKey appears before secondKey in control flow
  (
    // Case 1: Same basic block with firstKey at lower index
    exists(BasicBlock block, int firstIndex, int secondIndex |
      firstKey.getAFlowNode() = block.getNode(firstIndex) and
      secondKey.getAFlowNode() = block.getNode(secondIndex) and
      firstIndex < secondIndex
    )
    or
    // Case 2: firstKey's block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location information
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"