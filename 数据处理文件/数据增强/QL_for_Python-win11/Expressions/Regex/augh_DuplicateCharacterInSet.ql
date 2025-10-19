/**
 * @name Duplication in regular expression character class
 * @description Identifies duplicate characters within regex character classes which serve no functional purpose and may indicate developer errors.
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

// Predicate to detect duplicate characters within regex character classes
predicate duplicate_char_in_class(RegExp regex, string repeatedChar) {
  // Identify character class boundaries and validate character positions
  exists(int classStart, int classEnd |
    regex.charSet(classStart, classEnd) and
    // Locate two distinct character occurrences within the class
    exists(int char1Start, int char1End, int char2Start, int char2End |
      // Ensure character positions are different
      (char1Start != char2Start or char1End != char2End) and
      // Validate first character is within class boundaries
      classStart < char1Start and char1End < classEnd and
      // Validate second character is within class boundaries
      classStart < char2Start and char2End < classEnd and
      // Confirm first character is valid and extract its value
      regex.character(char1Start, char1End) and
      repeatedChar = regex.getText().substring(char1Start, char1End) and
      // Confirm second character is valid and matches first
      regex.character(char2Start, char2End) and
      repeatedChar = regex.getText().substring(char2Start, char2End)
    )
  ) and
  // Exclude special replacement character
  repeatedChar != "�" and
  // Ignore whitespace in VERBOSE mode
  not (
    regex.getAMode() = "VERBOSE" and
    repeatedChar in [" ", "\t", "\r", "\n"]
  )
}

// Query to find regex patterns with duplicate characters in character classes
from RegExp regex, string repeatedChar
where duplicate_char_in_class(regex, repeatedChar)
select regex,
  "Character class contains duplicate '" + repeatedChar + "' which has no effect and may indicate an error."