/**
 * @name Alert suppression analysis
 * @description Detects and analyzes alert suppression patterns in Python source code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression functionality
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling utilities
private import semmle.python.Comment as PythonComment

// Represents a Python comment on a single line with location information
class SingleLineComment instanceof PythonComment::Comment {
  // Verify if the comment has specific location details
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Ensure location data matches parent class information
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Retrieve the text content of the comment
  string getText() { result = super.getContents() }

  // Obtain string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node equipped with location tracking
class AstNode instanceof PythonComment::AstNode {
  // Confirm if the node has specific position information
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Validate location aligns with parent class data
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Generate string representation of the AST node
  string toString() { result = super.toString() }
}

// Create suppression associations between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * Suppression comment utilizing noqa directive. Recognized by popular Python linters
 * such as pylint and pyflakes, and consequently supported by lgtm.
 */
// Represents a suppression comment adhering to noqa convention
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor validating comment conforms to noqa pattern
  NoqaSuppressionComment() {
    // Detect comments containing case-insensitive noqa directive with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Determine code scope affected by this suppression directive
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Obtain comment location and verify it begins at the first column
    this.hasLocationInfo(sourceFilePath, beginLine, _, endLine, endColumn) and
    beginColumn = 1
  }
}