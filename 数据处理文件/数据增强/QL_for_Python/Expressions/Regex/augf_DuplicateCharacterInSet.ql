/**
 * @name Duplication in regular expression character class
 * @description Detects redundant duplicate characters within regex character classes
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

// Identifies duplicate characters within regex character classes
predicate duplicate_char_in_class(RegExp r, string char) {
  exists(
    int firstCharStart, int firstCharEnd,  // First character's position
    int secondCharStart, int secondCharEnd, // Second character's position
    int classStart, int classEnd            // Character class boundaries
  |
    // Ensure characters are at different positions
    firstCharStart != secondCharStart and
    firstCharEnd != secondCharEnd and
    
    // Verify both characters are within the character class
    classStart < firstCharStart and
    firstCharEnd < classEnd and
    classStart < secondCharStart and
    secondCharEnd < classEnd and
    
    // Confirm both positions represent valid characters
    r.character(firstCharStart, firstCharEnd) and
    char = r.getText().substring(firstCharStart, firstCharEnd) and
    r.character(secondCharStart, secondCharEnd) and
    char = r.getText().substring(secondCharStart, secondCharEnd) and
    
    // Ensure positions are within a character class
    r.charSet(classStart, classEnd)
  ) and
  // Exclude special placeholder character
  char != "�" and
  // Ignore whitespace in VERBOSE mode
  not (
    r.getAMode() = "VERBOSE" and
    char in [" ", "\t", "\r", "\n"]
  )
}

// Query to find regex patterns with duplicate characters in character classes
from RegExp r, string char
where duplicate_char_in_class(r, char)
select r, 
  "This regular expression includes duplicate character '" + char + "' in a set of characters."