/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing capabilities
private import semmle.python.Comment as P

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof P::AstNode {
  // Verify if node matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Generate string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with detailed location metadata
class SingleLineComment instanceof P::Comment {
  // Validate comment against specified location parameters
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

// Establish suppression framework using AlertSuppression template
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents noqa suppression comments. This format is recognized by
 * pylint, pyflakes, and LGTM analysis tools.
 */
// Models Python's noqa-style suppression mechanism
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by detecting noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract and validate comment location boundaries
    exists(int commentStartLine, int commentEndLine, int commentEndCol |
      // Retrieve comment's precise location
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndCol) and
      // Set coverage to match comment's line boundaries
      startLine = commentStartLine and
      endLine = commentEndLine and
      startCol = 1 and
      endCol = commentEndCol
    )
  }
}