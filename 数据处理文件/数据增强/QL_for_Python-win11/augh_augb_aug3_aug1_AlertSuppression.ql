/**
 * @name Alert suppression analysis
 * @description Detects and evaluates alert suppression mechanisms in Python source code,
 *              with special focus on 'noqa' style suppression comments. This analysis
 *              helps identify where warnings or alerts are intentionally suppressed
 *              by developers, which is crucial for security auditing.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for analysis
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities for comment extraction
private import semmle.python.Comment as PythonComment

// Represents a single-line Python comment with location tracking capabilities
class SingleLineComment instanceof PythonComment::Comment {
  // Check if comment has specific location information
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Verify location matches parent class location data
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Get the text content of the comment
  string getText() { result = super.getContents() }

  // Get string representation of the comment
  string toString() { result = super.toString() }
}

// Represents a Python AST node with location tracking capabilities
class AstNode instanceof PythonComment::AstNode {
  // Check if node has specific location information
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Verify location matches parent class location data
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Get string representation of the node
  string toString() { result = super.toString() }
}

// Generate suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * This class identifies and processes comments that suppress warnings in Python code.
 */
// Represents a noqa-style suppression comment that disables warnings
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
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Get comment location and verify it starts at column 1
    this.hasLocationInfo(sourceFilePath, beginLine, _, finishLine, finishColumn) and
    beginColumn = 1
  }
}