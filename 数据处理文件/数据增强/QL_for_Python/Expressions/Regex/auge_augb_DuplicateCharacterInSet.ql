/**
 * @name Duplication in regular expression character class
 * @description Identifies redundant duplicate characters within regex character classes
 * @kind problem
 * @tags reliability
 *       readability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/regex/duplicate-in-character-class
 */

import python
import semmle.python.regex

// Locates duplicate characters within the same regex character class
predicate find_duplicate_in_charclass(RegExp pattern, string repeatedChar) {
  exists(
    int classBegin, int classEnd,  // Character class boundaries
    int firstPosStart, int firstPosEnd,  // First character position
    int secondPosStart, int secondPosEnd  // Second character position
  |
    // Validate character class boundaries
    pattern.charSet(classBegin, classEnd) and
    
    // Ensure both characters are within the same character class
    classBegin < firstPosStart and firstPosEnd < classEnd and
    classBegin < secondPosStart and secondPosEnd < classEnd and
    
    // Confirm both positions represent valid characters
    pattern.character(firstPosStart, firstPosEnd) and
    pattern.character(secondPosStart, secondPosEnd) and
    
    // Verify character equivalence and distinct positions
    repeatedChar = pattern.getText().substring(firstPosStart, firstPosEnd) and
    repeatedChar = pattern.getText().substring(secondPosStart, secondPosEnd) and
    (firstPosStart != secondPosStart or firstPosEnd != secondPosEnd) and
    
    // Exclude unencodable character placeholder
    repeatedChar != "�" and
    
    // Skip whitespace in VERBOSE mode
    not (
      pattern.getAMode() = "VERBOSE" and 
      repeatedChar in [" ", "\t", "\r", "\n"]
    )
  )
}

// Detect regex patterns with duplicate characters in character classes
from RegExp pattern, string repeatedChar
where find_duplicate_in_charclass(pattern, repeatedChar)
select pattern, 
  "Duplicate character '" + repeatedChar + "' found in regex character class"