/**
 * @name Duplication in regular expression character class
 * @description Detects duplicate characters within regex character classes
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

// Identifies duplicate characters in regex character classes
predicate duplicate_char_in_class(RegExp regex, string duplicatedChar) {
  exists(
    int classStart, int classEnd,  // Character class boundaries
    int firstCharStart, int firstCharEnd,  // First character occurrence
    int secondCharStart, int secondCharEnd  // Second character occurrence
  |
    // Ensure both characters are within the same character class
    regex.charSet(classStart, classEnd) and
    classStart < firstCharStart and firstCharEnd < classEnd and
    classStart < secondCharStart and secondCharEnd < classEnd and
    
    // Verify both positions represent valid characters
    regex.character(firstCharStart, firstCharEnd) and
    regex.character(secondCharStart, secondCharEnd) and
    
    // Confirm characters are identical and positions are distinct
    duplicatedChar = regex.getText().substring(firstCharStart, firstCharEnd) and
    duplicatedChar = regex.getText().substring(secondCharStart, secondCharEnd) and
    (firstCharStart != secondCharStart or firstCharEnd != secondCharEnd) and
    
    // Exclude special unencodable character placeholder
    duplicatedChar != "�" and
    
    // Ignore whitespace in VERBOSE mode
    not (
      regex.getAMode() = "VERBOSE" and 
      duplicatedChar in [" ", "\t", "\r", "\n"]
    )
  )
}

// Find regex patterns containing duplicate characters in character classes
from RegExp regex, string duplicatedChar
where duplicate_char_in_class(regex, duplicatedChar)
select regex, 
  "Duplicate character '" + duplicatedChar + "' found in regex character class"