/**
 * @name Duplication in regular expression character class
 * @description Identifies duplicate characters within regex character classes
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

// Detects duplicate characters in regex character classes
predicate duplicate_char_in_class(RegExp regex, string repeatedCharacter) {
  exists(
    int charClassStart, int charClassEnd,  // Character class boundaries
    int firstCharPosStart, int firstCharPosEnd,  // First character occurrence
    int secondCharPosStart, int secondCharPosEnd  // Second character occurrence
  |
    // Locate character class containing both occurrences
    regex.charSet(charClassStart, charClassEnd) and
    
    // Verify both characters are within the same character class
    charClassStart < firstCharPosStart and firstCharPosEnd < charClassEnd and
    charClassStart < secondCharPosStart and secondCharPosEnd < charClassEnd and
    
    // Confirm both positions represent valid characters
    regex.character(firstCharPosStart, firstCharPosEnd) and
    regex.character(secondCharPosStart, secondCharPosEnd) and
    
    // Ensure characters are identical and positions are distinct
    repeatedCharacter = regex.getText().substring(firstCharPosStart, firstCharPosEnd) and
    repeatedCharacter = regex.getText().substring(secondCharPosStart, secondCharPosEnd) and
    (firstCharPosStart != secondCharPosStart or firstCharPosEnd != secondCharPosEnd) and
    
    // Exclude special unencodable character placeholder
    repeatedCharacter != "�" and
    
    // Ignore whitespace in VERBOSE mode
    not (
      regex.getAMode() = "VERBOSE" and 
      repeatedCharacter in [" ", "\t", "\r", "\n"]
    )
  )
}

// Identify regex patterns with duplicate characters in character classes
from RegExp regex, string repeatedCharacter
where duplicate_char_in_class(regex, repeatedCharacter)
select regex, 
  "Duplicate character '" + repeatedCharacter + "' found in regex character class"