/**
 * @name Duplication in regular expression character class
 * @description Duplicate characters in a class have no effect and may indicate an error in the regular expression.
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

// Predicate: Identifies duplicate characters within regex character classes
predicate duplicate_char_in_class(RegExp regex, string dupChar) {
  exists(
    int firstStart, int firstEnd, 
    int secondStart, int secondEnd,
    int classStart, int classEnd |
    
    // Verify distinct character positions
    firstStart != secondStart and
    firstEnd != secondEnd and
    
    // Confirm both characters reside within same character class
    classStart < firstStart and
    firstEnd < classEnd and
    classStart < secondStart and
    secondEnd < classEnd and
    
    // Extract and compare first character content
    regex.character(firstStart, firstEnd) and
    dupChar = regex.getText().substring(firstStart, firstEnd) and
    
    // Extract and compare second character content
    regex.character(secondStart, secondEnd) and
    dupChar = regex.getText().substring(secondStart, secondEnd) and
    
    // Validate character class boundaries
    regex.charSet(classStart, classEnd)
  ) and
  // Exclude invalid replacement character
  dupChar != "�" and
  // Ignore whitespace in VERBOSE mode
  not (
    regex.getAMode() = "VERBOSE" and
    dupChar in [" ", "\t", "\r", "\n"]
  )
}

// Main query: Detect regexes with duplicate characters in character classes
from RegExp regex, string dupChar
where duplicate_char_in_class(regex, dupChar)
select regex,
  "This regular expression includes duplicate character '" + dupChar + "' in a set of characters."