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
predicate duplicate_char_in_class(RegExp regex, string repeatedChar) {
  exists(
    int firstCharStart, int firstCharEnd, 
    int secondCharStart, int secondCharEnd,
    int classStart, int classEnd |
    
    // Ensure distinct character positions
    firstCharStart != secondCharStart and
    firstCharEnd != secondCharEnd and
    
    // Validate both characters reside within the same character class
    classStart < firstCharStart and
    firstCharEnd < classEnd and
    classStart < secondCharStart and
    secondCharEnd < classEnd and
    
    // Extract and match first character content
    regex.character(firstCharStart, firstCharEnd) and
    repeatedChar = regex.getText().substring(firstCharStart, firstCharEnd) and
    
    // Extract and match second character content
    regex.character(secondCharStart, secondCharEnd) and
    repeatedChar = regex.getText().substring(secondCharStart, secondCharEnd) and
    
    // Confirm character class boundaries
    regex.charSet(classStart, classEnd)
  ) and
  // Exclude special replacement character
  repeatedChar != "�" and
  // Skip whitespace in VERBOSE mode
  not (
    regex.getAMode() = "VERBOSE" and
    repeatedChar in [" ", "\t", "\r", "\n"]
  )
}

// Main query: Detect regexes with duplicate characters in character classes
from RegExp regex, string repeatedChar
where duplicate_char_in_class(regex, repeatedChar)
select regex,
  "This regular expression includes duplicate character '" + repeatedChar + "' in a set of characters."