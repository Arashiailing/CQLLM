/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python source code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as PythonComment

// Represents a single-line Python comment with location tracking
class SingleLineComment instanceof PythonComment::Comment {
  // Retrieve location information for the comment
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract location details from parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Extract the textual content of the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node equipped with location tracking
class AstNode instanceof PythonComment::AstNode {
  // Retrieve location information for the AST node
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract location details from parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Provide string representation of the AST node
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment for alert suppression
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by identifying noqa pattern in comment text
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code range affected by this suppression
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract comment location and verify it starts at column 1
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}