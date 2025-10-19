/**
 * @name Alert suppression
 * @description Provides information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing capabilities
private import semmle.python.Comment as P

// Encapsulates AST nodes with precise location tracking functionality
class AstNode instanceof P::AstNode {
  // Determine if node matches the given location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Generate a string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with detailed location information
class SingleLineComment instanceof P::Comment {
  // Check if comment corresponds to the specified location
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Extract the textual content of the comment
  string getText() { result = super.getContents() }

  // Generate a string representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationships using the AlertSuppression template
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. This format is recognized by both pylint and pyflakes,
 * and therefore should also be respected by LGTM analysis.
 */
// Models noqa-style suppression comments in Python code
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by identifying noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the code coverage scope for this suppression
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract and validate location details from the comment
    exists(int commentLineStart, int commentLineEnd, int commentColumnEnd |
      // Retrieve the comment's location boundaries
      this.hasLocationInfo(filePath, commentLineStart, _, commentLineEnd, commentColumnEnd) and
      // Set the coverage to match the comment's line boundaries
      startLine = commentLineStart and
      endLine = commentLineEnd and
      startCol = 1 and
      endCol = commentColumnEnd
    )
  }
}