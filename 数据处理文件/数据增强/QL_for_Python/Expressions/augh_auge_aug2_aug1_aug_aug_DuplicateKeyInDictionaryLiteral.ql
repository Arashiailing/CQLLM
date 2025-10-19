/**
 * @name Duplicate key in dict literal
 * @description Detects dictionary literals containing duplicate keys where initial occurrences are silently overwritten by subsequent ones
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

// Generates standardized string representations for dictionary keys
// Handles numeric values and string literals with appropriate type prefixes
predicate getCanonicalKeyString(Dict dictLiteral, Expr keyExpr, string canonicalKeyStr) {
  keyExpr = dictLiteral.getAKey() and
  (
    // Numeric keys: convert value directly to string
    canonicalKeyStr = keyExpr.(Num).getN()
    or
    // String literals: add type prefix and validate content
    exists(StringLiteral strLit | 
      strLit = keyExpr and
      not "�" = strLit.getText().charAt(_) and  // Check for invalid characters
      (
        // Unicode strings: prefix with 'u'
        canonicalKeyStr = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
        or
        // Byte strings: prefix with 'b'
        canonicalKeyStr = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
      )
    )
  )
}

// Locate dictionary literals with duplicate keys
from Dict dictLiteral, Expr initialKey, Expr duplicateKey
where
  // Both keys produce identical canonical representations
  exists(string canonicalKeyStr | 
    getCanonicalKeyString(dictLiteral, initialKey, canonicalKeyStr) and 
    getCanonicalKeyString(dictLiteral, duplicateKey, canonicalKeyStr) and 
    initialKey != duplicateKey
  ) and
  // Verify positional relationship between keys
  (
    // Case 1: Keys reside in same basic block with initialKey preceding duplicateKey
    exists(BasicBlock containingBlock, int initialPos, int duplicatePos |
      initialKey.getAFlowNode() = containingBlock.getNode(initialPos) and
      duplicateKey.getAFlowNode() = containingBlock.getNode(duplicatePos) and
      initialPos < duplicatePos
    )
    or
    // Case 2: initialKey's basic block strictly dominates duplicateKey's block
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      duplicateKey.getAFlowNode().getBasicBlock()
    )
  )
// Report alert showing which key overwrites the initial occurrence
select initialKey, 
       "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
       duplicateKey, 
       "overwritten"