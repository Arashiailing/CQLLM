/**
 * @name Alert suppression analysis
 * @description Identifies and analyzes alert suppression mechanisms in Python source code,
 *              with particular emphasis on 'noqa' style suppression comments.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for analysis
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities for comment extraction
private import semmle.python.Comment as PythonComment

// Represents a single-line Python comment equipped with location tracking functionality
class SingleLineComment instanceof PythonComment::Comment {
  // Determine if comment possesses specific location information
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Validate that location corresponds to parent class location data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Retrieve the text content of the comment
  string getText() { result = super.getContents() }

  // Obtain string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node equipped with location tracking functionality
class AstNode instanceof PythonComment::AstNode {
  // Determine if node possesses specific location information
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Validate that location corresponds to parent class location data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Obtain string representation of the node
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment designed to disable warnings
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that verifies comment matches noqa pattern
  NoqaSuppressionComment() {
    // Identify case-insensitive noqa with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Specify the code range affected by this suppression
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Extract comment location and confirm it starts at column 1
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}