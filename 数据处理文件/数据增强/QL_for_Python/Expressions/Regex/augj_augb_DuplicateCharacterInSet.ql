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
    int charClassStart, int charClassEnd,  // Character class boundaries
    int firstOccurrenceStart, int firstOccurrenceEnd,  // First character occurrence
    int secondOccurrenceStart, int secondOccurrenceEnd  // Second character occurrence
  |
    // Locate character class and verify both characters are within it
    regex.charSet(charClassStart, charClassEnd) and
    charClassStart < firstOccurrenceStart and firstOccurrenceEnd < charClassEnd and
    charClassStart < secondOccurrenceStart and secondOccurrenceEnd < charClassEnd and
    
    // Validate both positions represent legitimate characters
    regex.character(firstOccurrenceStart, firstOccurrenceEnd) and
    regex.character(secondOccurrenceStart, secondOccurrenceEnd) and
    
    // Confirm character match and distinct positions
    duplicatedChar = regex.getText().substring(firstOccurrenceStart, firstOccurrenceEnd) and
    duplicatedChar = regex.getText().substring(secondOccurrenceStart, secondOccurrenceEnd) and
    (firstOccurrenceStart != secondOccurrenceStart or firstOccurrenceEnd != secondOccurrenceEnd) and
    
    // Exclude unencodable character placeholder
    duplicatedChar != "�" and
    
    // Skip whitespace in VERBOSE mode
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