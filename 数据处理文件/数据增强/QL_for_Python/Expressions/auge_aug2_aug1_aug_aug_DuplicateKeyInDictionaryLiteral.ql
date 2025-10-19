/**
 * @name Duplicate key in dict literal
 * @description Identifies dictionary literals containing duplicate keys where initial occurrences are silently overwritten by subsequent ones
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
predicate getCanonicalKeyString(Dict dictObj, Expr keyValue, string canonicalStr) {
  keyValue = dictObj.getAKey() and
  (
    // Numeric keys: convert value directly to string
    canonicalStr = keyValue.(Num).getN()
    or
    // String literals: add type prefix and validate content
    exists(StringLiteral strLiteral | 
      strLiteral = keyValue and
      not "�" = strLiteral.getText().charAt(_) and  // Check for invalid characters
      (
        // Unicode strings: prefix with 'u'
        canonicalStr = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        // Byte strings: prefix with 'b'
        canonicalStr = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// Locate dictionary literals with duplicate keys
from Dict dictObj, Expr firstKey, Expr secondKey
where
  // Both keys produce identical canonical representations
  exists(string canonicalStr | 
    getCanonicalKeyString(dictObj, firstKey, canonicalStr) and 
    getCanonicalKeyString(dictObj, secondKey, canonicalStr) and 
    firstKey != secondKey
  ) and
  // Verify positional relationship between keys
  (
    // Case 1: Keys reside in same basic block with firstKey preceding secondKey
    exists(BasicBlock containingBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = containingBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = containingBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // Case 2: firstKey's basic block strictly dominates secondKey's block
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// Report alert showing which key overwrites the initial occurrence
select firstKey, 
       "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
       secondKey, 
       "overwritten"