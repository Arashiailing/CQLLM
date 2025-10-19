/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppressions in Python code, specifically focusing on noqa-style comments.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as P

// Represents a Python AST node with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Check if node has specific location information
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Verify location matches parent class location data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Get string representation of the node
  string toString() { result = super.toString() }
}

// Represents a single-line Python comment
class SingleLineComment instanceof P::Comment {
  // Check if comment has specific location information
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Verify location matches parent class location data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Get the text content of the comment
  string getText() { result = super.getContents() }

  // Get string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by checking comment matches noqa pattern
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Get the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code range covered by this suppression
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Get comment location and verify it starts at column 1
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}