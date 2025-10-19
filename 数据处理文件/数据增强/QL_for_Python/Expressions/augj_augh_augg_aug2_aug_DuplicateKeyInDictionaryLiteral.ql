/**
 * @name Duplicate Key in Dictionary Literal
 * @description Identifies dictionary literals containing duplicate keys, where the initial value is silently overwritten by a later one.
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
 * Generates a canonical string form for dictionary key expressions.
 * Numeric keys are represented by their numeric value.
 * String keys are represented with their Unicode or byte prefix, excluding those with special characters to prevent false positives.
 */
predicate canonicalKeyRepresentation(Dict dictionary, Expr keyExpr, string canonicalForm) {
  // Verify key belongs to the dictionary
  keyExpr = dictionary.getAKey() and
  (
    // Numeric keys use their numeric value as canonical form
    canonicalForm = keyExpr.(Num).getN()
    or
    // String keys: exclude those with special characters
    not "�" = canonicalForm.charAt(_) and
    // Handle string literals with proper Unicode/byte prefixes
    exists(StringLiteral strLit | strLit = keyExpr |
      canonicalForm = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      canonicalForm = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// Identify duplicate key pairs within the same dictionary
from Dict dictionary, Expr firstKey, Expr secondKey
where
  // Keys must have identical canonical forms but be distinct expressions
  exists(string canonicalForm | 
    canonicalKeyRepresentation(dictionary, firstKey, canonicalForm) and 
    canonicalKeyRepresentation(dictionary, secondKey, canonicalForm) and 
    firstKey != secondKey
  ) and
  (
    // Case 1: Keys in same basic block with firstKey preceding secondKey
    exists(BasicBlock sharedBlock, int firstIndex, int secondIndex |
      firstKey.getAFlowNode() = sharedBlock.getNode(firstIndex) and
      secondKey.getAFlowNode() = sharedBlock.getNode(secondIndex) and
      firstIndex < secondIndex
    )
    or
    // Case 2: firstKey's block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Generate warning highlighting the overwrite location
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"