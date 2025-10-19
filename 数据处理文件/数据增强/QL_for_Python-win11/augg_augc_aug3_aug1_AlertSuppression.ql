/**
 * @name Alert suppression analysis
 * @description Identifies and evaluates alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as PythonComment

// Represents a single-line Python comment with location tracking
class SingleLineComment instanceof PythonComment::Comment {
  // Check if comment has specific location details
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Validate location matches parent class information
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Get the text content of the comment
  string getText() { result = super.getContents() }

  // Get string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node with location capabilities
class AstNode instanceof PythonComment::AstNode {
  // Verify node has specific positional information
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Confirm location aligns with parent class data
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Generate string representation of AST node
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * Suppression comment using noqa directive. Recognized by pylint and pyflakes linters,
 * and therefore supported by lgtm as well.
 */
// Represents a suppression comment following noqa convention
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor verifying comment matches noqa pattern
  NoqaSuppressionComment() {
    // Identify comments with case-insensitive noqa directive and optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Get annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define code scope covered by this suppression directive
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Extract comment location and ensure it starts at first column
    this.hasLocationInfo(sourceFilePath, beginLine, _, endLine, endColumn) and
    beginColumn = 1
  }
}