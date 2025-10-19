/**
 * @name Duplication in regular expression character class
 * @description Identifies redundant duplicate characters within regex character classes that serve no purpose and may indicate logical errors.
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

// Predicate: Determines if a regex pattern contains duplicate characters within any character class
predicate containsDuplicateInCharClass(RegExp pattern, string repeatedCharacter) {
  exists(
    int firstCharBegin, int firstCharFinish, 
    int secondCharBegin, int secondCharFinish,
    int charSetBegin, int charSetFinish
  |
    // Ensure the two character positions are distinct
    not (firstCharBegin = secondCharBegin and firstCharFinish = secondCharFinish) and
    
    // Verify both characters are within the same character class
    charSetBegin < firstCharBegin and firstCharFinish < charSetFinish and
    charSetBegin < secondCharBegin and secondCharFinish < charSetFinish and
    
    // Confirm both positions represent valid characters
    pattern.character(firstCharBegin, firstCharFinish) and
    pattern.character(secondCharBegin, secondCharFinish) and
    
    // Extract and compare the actual character values
    repeatedCharacter = pattern.getText().substring(firstCharBegin, firstCharFinish) and
    repeatedCharacter = pattern.getText().substring(secondCharBegin, secondCharFinish) and
    
    // Validate the character class boundaries
    pattern.charSet(charSetBegin, charSetFinish)
  ) and
  // Exclude the special replacement character used for unencodable characters
  repeatedCharacter != "�" and
  // Skip whitespace characters in VERBOSE mode where they are insignificant
  not (
    pattern.getAMode() = "VERBOSE" and 
    repeatedCharacter in [" ", "\t", "\r", "\n"]
  )
}

// Main query: Find regex patterns containing duplicate characters in character classes
from RegExp pattern, string repeatedCharacter
where containsDuplicateInCharClass(pattern, repeatedCharacter)
select pattern, 
  "Regular expression contains duplicate character '" + repeatedCharacter + "' in character class."