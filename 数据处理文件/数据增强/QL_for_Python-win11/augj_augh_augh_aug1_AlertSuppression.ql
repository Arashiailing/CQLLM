/**
 * @name Alert suppression
 * @description Detects and analyzes alert suppression mechanisms in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as P

// Represents a Python AST node with enhanced location tracking capabilities
class PythonAstNode instanceof P::AstNode {
  // Verify node location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Ensure coordinates match parent class location data
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Get string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents a single-line Python comment with precise location tracking
class PythonSingleLineComment instanceof P::Comment {
  // Verify comment location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Ensure coordinates match parent class location data
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Get the text content of the comment
  string getText() { result = super.getContents() }

  // Get string representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<PythonAstNode, PythonSingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment for alert suppression
class NoqaSuppressionComment extends SuppressionComment instanceof PythonSingleLineComment {
  // Initialize by verifying comment matches noqa pattern
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Get the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code range covered by this suppression
  override predicate covers(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Retrieve comment location and verify it starts at column 1
    this.hasLocationInfo(filePath, beginLine, _, finishLine, finishColumn) and
    beginColumn = 1
  }
}