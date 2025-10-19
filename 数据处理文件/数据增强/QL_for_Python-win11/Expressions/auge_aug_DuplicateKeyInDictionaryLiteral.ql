/**
 * @name Duplicate key in dictionary literal
 * @description Identifies dictionary literals containing duplicate keys, where all but the final occurrence are overwritten
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
 * Converts a dictionary key expression to its canonical string representation
 * for comparison purposes. This handles numeric keys and string literals
 * (both Unicode and byte strings).
 */
predicate normalizeKeyRepresentation(Dict dict, Expr keyExpr, string canonicalForm) {
  // Verify the expression is indeed a key in the dictionary
  keyExpr = dict.getAKey() and
  (
    // Handle numeric keys by using their numeric value as the representation
    canonicalForm = keyExpr.(Num).getN()
    or
    // Process string literal keys (excluding those with special characters)
    not "�" = canonicalForm.charAt(_) and
    // Handle string literals, distinguishing between Unicode and byte strings
    exists(StringLiteral stringLiteral | stringLiteral = keyExpr |
      canonicalForm = "u\"" + stringLiteral.getText() + "\"" and stringLiteral.isUnicode()
      or
      canonicalForm = "b\"" + stringLiteral.getText() + "\"" and not stringLiteral.isUnicode()
    )
  )
}

/**
 * Identifies pairs of duplicate keys within dictionary literals.
 * A key is considered duplicate if it has the same canonical representation
 * as another key but appears earlier in the code flow.
 */
from Dict dict, Expr initialKey, Expr subsequentKey
where
  // Both keys share the same canonical representation but are different expressions
  exists(string keyCanonicalForm | 
    normalizeKeyRepresentation(dict, initialKey, keyCanonicalForm) and 
    normalizeKeyRepresentation(dict, subsequentKey, keyCanonicalForm) and 
    initialKey != subsequentKey
  ) and
  (
    // Case 1: Both keys are in the same basic block with initialKey appearing first
    exists(BasicBlock sharedBlock, int initialPosition, int subsequentPosition |
      initialKey.getAFlowNode() = sharedBlock.getNode(initialPosition) and
      subsequentKey.getAFlowNode() = sharedBlock.getNode(subsequentPosition) and
      initialPosition < subsequentPosition
    )
    or
    // Case 2: The basic block containing initialKey strictly dominates the block containing subsequentKey
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate alert for duplicate key, highlighting the overwriting position
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
  subsequentKey, 
  "overwritten"