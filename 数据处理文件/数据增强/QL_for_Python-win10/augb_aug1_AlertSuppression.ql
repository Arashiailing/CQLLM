/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as P

// Represents a Python AST node with location tracking
class AstNode instanceof P::AstNode {
  // Retrieve location details for the AST node
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Provide string representation of the node
  string toString() { result = super.toString() }
}

// Represents a single-line Python comment
class SingleLineComment instanceof P::Comment {
  // Retrieve location details for the comment
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Get the text content of the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa comment pattern
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
    // Ensure comment starts at column 1 and get its location
    startColumn = 1 and
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn)
  }
}