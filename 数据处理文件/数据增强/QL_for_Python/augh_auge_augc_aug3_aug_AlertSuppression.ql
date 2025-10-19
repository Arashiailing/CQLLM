/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing capabilities
private import semmle.python.Comment as P

// AST node wrapper with enhanced location tracking capabilities
class AstNode instanceof P::AstNode {
  // Verify node location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Generate string representation of AST node
  string toString() { result = super.toString() }
}

// Detailed single-line comment representation with location metadata
class SingleLineComment instanceof P::Comment {
  // Validate comment location against specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Retrieve textual content of the comment
  string getText() { result = super.getContents() }

  // Generate string representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationships using AlertSuppression framework
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Recognized by pylint and pyflakes,
 * and should be respected by LGTM analysis.
 */
// Implementation of noqa-style suppression comments
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor: Identify noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract and validate location details from comment
    exists(
      int commentStartLine, int commentEndLine, int commentEndColumn |
      // Retrieve comment location boundaries
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndColumn) and
      // Set coverage to match comment's line boundaries
      startLine = commentStartLine and
      endLine = commentEndLine and
      startCol = 1 and
      endCol = commentEndColumn
    )
  }
}