/**
 * @name Duplication in regular expression character class
 * @description Identifies redundant duplicate characters within regex character classes, 
 *              which have no functional effect but may indicate developer errors.
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

// Predicate: Detects duplicate characters within regex character classes
predicate duplicate_char_in_class(RegExp regexPattern, string duplicatedChar) {
  exists(
    int firstCharStartPos, int firstCharEndPos, 
    int secondCharStartPos, int secondCharEndPos,
    int charClassStartPos, int charClassEndPos |
    
    // Verify distinct character positions
    firstCharStartPos != secondCharStartPos and
    firstCharEndPos != secondCharEndPos and
    
    // Confirm both characters belong to same character class
    charClassStartPos < firstCharStartPos and
    firstCharEndPos < charClassEndPos and
    charClassStartPos < secondCharStartPos and
    secondCharEndPos < charClassEndPos and
    
    // Extract and match first character
    regexPattern.character(firstCharStartPos, firstCharEndPos) and
    duplicatedChar = regexPattern.getText().substring(firstCharStartPos, firstCharEndPos) and
    
    // Extract and match second character
    regexPattern.character(secondCharStartPos, secondCharEndPos) and
    duplicatedChar = regexPattern.getText().substring(secondCharStartPos, secondCharEndPos) and
    
    // Validate character class boundaries
    regexPattern.charSet(charClassStartPos, charClassEndPos)
  ) and
  // Exclude invalid replacement character
  duplicatedChar != "�" and
  // Ignore whitespace in VERBOSE mode
  not (
    regexPattern.getAMode() = "VERBOSE" and
    duplicatedChar in [" ", "\t", "\r", "\n"]
  )
}

// Main query: Identifies regex patterns containing duplicate characters in character classes
from RegExp regexPattern, string duplicatedChar
where duplicate_char_in_class(regexPattern, duplicatedChar)
select regexPattern,
  "This regular expression includes duplicate character '" + duplicatedChar + "' in a set of characters."