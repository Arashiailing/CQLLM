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

// Detects identical characters appearing multiple times within a single regex character class
predicate locate_duplicate_in_charclass(RegExp regexPattern, string duplicateChar) {
  exists(
    int charClassStart, int charClassEnd,  // Boundaries of the character class
    int firstOccurrenceStart, int firstOccurrenceEnd,  // Position of first character instance
    int secondOccurrenceStart, int secondOccurrenceEnd  // Position of second character instance
  |
    // Verify character class boundaries exist
    regexPattern.charSet(charClassStart, charClassEnd) and
    
    // Ensure both character instances are within the same character class
    charClassStart < firstOccurrenceStart and firstOccurrenceEnd < charClassEnd and
    charClassStart < secondOccurrenceStart and secondOccurrenceEnd < charClassEnd and
    
    // Confirm both positions represent valid characters
    regexPattern.character(firstOccurrenceStart, firstOccurrenceEnd) and
    regexPattern.character(secondOccurrenceStart, secondOccurrenceEnd) and
    
    // Validate character equivalence and distinct positions
    duplicateChar = regexPattern.getText().substring(firstOccurrenceStart, firstOccurrenceEnd) and
    duplicateChar = regexPattern.getText().substring(secondOccurrenceStart, secondOccurrenceEnd) and
    (firstOccurrenceStart != secondOccurrenceStart or firstOccurrenceEnd != secondOccurrenceEnd) and
    
    // Exclude unencodable character placeholder
    duplicateChar != "�" and
    
    // Ignore whitespace characters in VERBOSE mode
    not (
      regexPattern.getAMode() = "VERBOSE" and 
      duplicateChar in [" ", "\t", "\r", "\n"]
    )
  )
}

// Identify regex patterns containing duplicate characters in character classes
from RegExp regexPattern, string duplicateChar
where locate_duplicate_in_charclass(regexPattern, duplicateChar)
select regexPattern, 
  "Duplicate character '" + duplicateChar + "' found in regex character class"