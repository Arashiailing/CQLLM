/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for processing suppression annotations
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities for handling Python-specific comment syntax
private import semmle.python.Comment as PythonComment

// Represents a single-line Python comment with enhanced location tracking
class SingleLineComment instanceof PythonComment::Comment {
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

// Represents a Python AST node with precise location tracking for suppression analysis
class AstNode instanceof PythonComment::AstNode {
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

// Generate suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment for suppressing alerts in Python code
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