/**
 * @name Duplicate key in dictionary literal
 * @description Detects dictionary literals with duplicate keys where earlier occurrences are overwritten
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
 * Transforms dictionary key expressions into standardized string formats
 * to enable comparison. Handles both numeric values and string literals
 * (including both Unicode and byte strings).
 */
predicate normalizedKeyFormat(Dict dictObj, Expr keyExpr, string standardForm) {
  keyExpr = dictObj.getAKey() and
  (
    // For numeric keys, use their numeric value as the standard form
    standardForm = keyExpr.(Num).getN()
    or
    // For string literals, normalize by adding appropriate prefix and text
    not "�" = standardForm.charAt(_) and
    exists(StringLiteral strLiteral | strLiteral = keyExpr |
      standardForm = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
      or
      standardForm = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
    )
  )
}

// Identify dictionaries containing duplicate keys where the first occurrence gets overwritten
from Dict targetDict, Expr initialKey, Expr duplicateKey
where
  // Both keys have identical normalized forms but represent different expressions
  exists(string normalizedKey | 
    normalizedKeyFormat(targetDict, initialKey, normalizedKey) and 
    normalizedKeyFormat(targetDict, duplicateKey, normalizedKey) and 
    initialKey != duplicateKey
  ) and
  (
    // Scenario 1: Keys exist within the same basic block with initialKey appearing before duplicateKey
    exists(BasicBlock containingBlock, int initialPosition, int duplicatePosition |
      initialKey.getAFlowNode() = containingBlock.getNode(initialPosition) and
      duplicateKey.getAFlowNode() = containingBlock.getNode(duplicatePosition) and
      initialPosition < duplicatePosition
    )
    or
    // Scenario 2: The basic block containing initialKey strictly dominates the block containing duplicateKey
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the duplicate key issue with location of the overwrite
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
  duplicateKey, 
  "overwritten"