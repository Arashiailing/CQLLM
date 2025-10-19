/**
 * @name Alert suppression
 * @description Detects and processes alert suppressions in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression functionality
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling utilities
private import semmle.python.Comment as P

// Represents a Python AST node equipped with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Extract location information for the AST node
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Forward location retrieval to the parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  // Generate a string representation of the node
  string toString() { result = super.toString() }
}

// Represents an individual Python comment line
class SingleLineComment instanceof P::Comment {
  // Extract location information for the comment
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Forward location retrieval to the parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  // Retrieve the actual text content of the comment
  string getText() { result = super.getContents() }

  // Generate a string representation of the comment
  string toString() { result = super.toString() }
}

// Establish the relationship between AST nodes and suppression comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa-style suppression comment. Both pylint and pyflakes respect this syntax,
 * making it a standard for alert suppression in Python code.
 */
// Represents a suppression comment using the noqa convention
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that identifies noqa comments
  NoqaSuppressionComment() {
    // Match case-insensitive noqa pattern with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code range affected by this suppression
  override predicate covers(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Ensure comment begins at column 1 and retrieve its location
    startColumn = 1 and
    this.hasLocationInfo(filePath, startLine, _, finishLine, finishColumn)
  }
}