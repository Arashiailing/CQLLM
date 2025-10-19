/**
 * @name Duplicate key in dict literal
 * @description Detects dictionary literals with duplicate keys where earlier values are silently overwritten
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
 * Converts dictionary key expressions to canonical string representations.
 * Handles numeric keys directly and string keys with Unicode/byte prefixes.
 * Excludes keys containing special characters to avoid false positives.
 */
predicate canonicalKeyRepresentation(Dict dictObj, Expr keyNode, string canonicalKey) {
  // Verify key belongs to the dictionary
  keyNode = dictObj.getAKey() and
  (
    // Numeric keys use their numeric value as canonical form
    canonicalKey = keyNode.(Num).getN()
    or
    // String keys: exclude those with special characters
    not "�" = canonicalKey.charAt(_) and
    // Handle string literals with proper Unicode/byte prefixes
    exists(StringLiteral strLit | strLit = keyNode |
      canonicalKey = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      canonicalKey = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate key pairs within the same dictionary
from Dict dictObj, Expr initialKey, Expr subsequentKey
where
  // Keys must have identical canonical forms but be distinct expressions
  exists(string canonicalKey | 
    canonicalKeyRepresentation(dictObj, initialKey, canonicalKey) and 
    canonicalKeyRepresentation(dictObj, subsequentKey, canonicalKey) and 
    initialKey != subsequentKey
  ) and
  (
    // Case 1: Keys in same basic block with initialKey preceding subsequentKey
    exists(BasicBlock commonBlock, int initialIdx, int subsequentIdx |
      initialKey.getAFlowNode() = commonBlock.getNode(initialIdx) and
      subsequentKey.getAFlowNode() = commonBlock.getNode(subsequentIdx) and
      initialIdx < subsequentIdx
    )
    or
    // Case 2: initialKey's block strictly dominates subsequentKey's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate warning highlighting the overwrite location
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
  subsequentKey, 
  "overwritten"