/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals with duplicate keys where initial values are overwritten by subsequent definitions.
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

// Normalizes dictionary keys to comparable string representations
// Handles numeric types (direct conversion) and string literals (with type-specific prefixes)
predicate normalizedKeyForm(Dict dict, Expr key, string normalizedForm) {
  key = dict.getAKey() and
  (
    // Numeric keys: convert value directly to string
    normalizedForm = key.(Num).getN()
    or
    // String literals: add type-specific prefixes for accurate comparison
    exists(StringLiteral strLiteral | 
      strLiteral = key and
      (
        // Unicode strings: prefix with 'u"'
        normalizedForm = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: prefix with 'b"'
        normalizedForm = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Identify dictionary keys where later occurrences overwrite earlier ones
from Dict dict, Expr initialKey, Expr subsequentKey
where
  // Keys have identical normalized representations
  exists(string normalizedKey | 
    normalizedKeyForm(dict, initialKey, normalizedKey) and 
    normalizedKeyForm(dict, subsequentKey, normalizedKey) and 
    initialKey != subsequentKey
  ) and
  // Initial key appears before subsequent key
  (
    // Case 1: Keys in same basic block with initial key at lower index
    exists(BasicBlock block, int initialIdx, int subsequentIdx |
      initialKey.getAFlowNode() = block.getNode(initialIdx) and
      subsequentKey.getAFlowNode() = block.getNode(subsequentIdx) and
      initialIdx < subsequentIdx
    )
    or
    // Case 2: Initial key's block strictly dominates subsequent key's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Report the overwritten key with location of overwriting key
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       subsequentKey, 
       "overwritten"