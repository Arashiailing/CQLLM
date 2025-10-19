/**
 * @name Alert suppression analysis
 * @description Identifies and evaluates alert suppression mechanisms in Python code,
 *              focusing on 'noqa' style suppression comments. This analysis reveals
 *              where developers intentionally disable warnings, which is critical
 *              for security auditing and code quality assessment.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as PythonComment
// Import suppression relationship generator
import AS::Make<AstNode, SingleLineComment>

// Represents a single-line Python comment with location tracking
class SingleLineComment instanceof PythonComment::Comment {
  // Retrieve location information for the comment
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Delegate to parent class location tracking
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Extract the text content of the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node with location tracking
class AstNode instanceof PythonComment::AstNode {
  // Retrieve location information for the AST node
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Delegate to parent class location tracking
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Provide string representation of the AST node
  string toString() { result = super.toString() }
}

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this,
 * so lgtm ought to too. Identifies comments that suppress warnings.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa pattern in comment text
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the annotation identifier for this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code range covered by this suppression
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Get comment location and verify it starts at column 1
    this.hasLocationInfo(sourceFilePath, beginLine, _, finishLine, finishColumn) and
    beginColumn = 1
  }
}