/**
 * @name Duplication in regular expression character class
 * @description Identifies duplicate characters within regex character classes which have no effect and may indicate a logical error.
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

/**
 * Predicate to detect duplicate characters within regular expression character classes.
 * @param regex The regular expression being analyzed.
 * @param duplicatedCharacter The character that appears more than once in a character class.
 */
predicate duplicate_char_in_class(RegExp regex, string duplicatedCharacter) {
  exists(
    int initialCharStart, int initialCharEnd, 
    int subsequentCharStart, int subsequentCharEnd,
    int charClassStart, int charClassEnd |
    
    // Ensure the two character positions are distinct
    initialCharStart != subsequentCharStart and
    initialCharEnd != subsequentCharEnd and
    
    // Verify both characters are within the character class boundaries
    charClassStart < initialCharStart and
    initialCharEnd < charClassEnd and
    charClassStart < subsequentCharStart and
    subsequentCharEnd < charClassEnd and
    
    // Extract and verify the content of both characters
    regex.character(initialCharStart, initialCharEnd) and
    regex.character(subsequentCharStart, subsequentCharEnd) and
    duplicatedCharacter = regex.getText().substring(initialCharStart, initialCharEnd) and
    duplicatedCharacter = regex.getText().substring(subsequentCharStart, subsequentCharEnd) and
    
    // Confirm these characters are part of a character set
    regex.charSet(charClassStart, charClassEnd)
  ) and
  // Exclude the special character '�' which represents unencodable characters
  duplicatedCharacter != "�" and
  // Ignore whitespace characters in verbose mode
  not (
    regex.getAMode() = "VERBOSE" and
    duplicatedCharacter in [" ", "\t", "\r", "\n"]
  )
}

// Main query: Identifies all regular expressions containing duplicate characters in character classes
from RegExp regex, string duplicatedCharacter
where duplicate_char_in_class(regex, duplicatedCharacter)
select regex,
  "This regular expression includes duplicate character '" + duplicatedCharacter + "' in a set of characters."