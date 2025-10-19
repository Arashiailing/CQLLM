/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where initial values are silently replaced by subsequent ones.
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

// Transforms dictionary keys into normalized string formats to enable accurate comparison
// Processes numeric types (direct value conversion) and string literals (with type-specific prefixes)
predicate normalizedKeyForm(Dict dict, Expr key, string normalizedString) {
  key = dict.getAKey() and
  (
    // Handle numeric keys by converting their value to string representation
    normalizedString = key.(Num).getN()
    or
    // Process string literals with appropriate type prefixes
    exists(StringLiteral strLiteral | 
      strLiteral = key and
      (
        // Unicode strings get 'u"' prefix
        normalizedString = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings get 'b"' prefix
        normalizedString = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Identify dictionary keys that are duplicated and overwrite previous occurrences
from Dict dict, Expr initialKey, Expr duplicateKey
where
  // Both keys must have identical normalized representations
  exists(string keyIdentifier | 
    normalizedKeyForm(dict, initialKey, keyIdentifier) and 
    normalizedKeyForm(dict, duplicateKey, keyIdentifier) and 
    initialKey != duplicateKey
  ) and
  // Validate the temporal sequence of key occurrences
  (
    // Scenario 1: Keys exist within the same basic block with initial key appearing first
    exists(BasicBlock codeBlock, int initialPosition, int duplicatePosition |
      initialKey.getAFlowNode() = codeBlock.getNode(initialPosition) and
      duplicateKey.getAFlowNode() = codeBlock.getNode(duplicatePosition) and
      initialPosition < duplicatePosition
    )
    or
    // Scenario 2: Initial key's basic block strictly dominates duplicate key's basic block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location of the overwriting duplicate
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       duplicateKey, 
       "overwritten"