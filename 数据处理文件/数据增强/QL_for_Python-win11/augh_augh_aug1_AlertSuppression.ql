/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as P

// Represents a Python AST node with location tracking capabilities
class PythonAstNode instanceof P::AstNode {
  // Verify node location matches specified coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure coordinates match parent class location data
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  // Get string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents a single-line Python comment with location tracking
class PythonSingleLineComment instanceof P::Comment {
  // Verify comment location matches specified coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure coordinates match parent class location data
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
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
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve comment location and verify it starts at column 1
    this.hasLocationInfo(file, startLine, _, endLine, endCol) and
    startCol = 1
  }
}