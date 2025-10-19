/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities for handling suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities for analyzing comment content
private import semmle.python.Comment as P

// Represents a Python AST node with comprehensive location tracking capabilities
class AstNode instanceof P::AstNode {
  // Determine if this node has specific location information
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Verify location details match parent class location data
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Retrieve string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents a single-line Python comment with location and content tracking
class SingleLineComment instanceof P::Comment {
  // Determine if this comment has specific location information
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Verify location details match parent class location data
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, endLine, endColumn)
  }

  // Retrieve the text content of the comment
  string getText() { result = super.getContents() }

  // Retrieve string representation of the comment
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment that can suppress alerts
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by verifying the comment matches the noqa pattern
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix or error codes
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier for this suppression mechanism
  override string getAnnotation() { result = "lgtm" }

  // Define the code range covered by this suppression comment
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int endLine, int endColumn
  ) {
    // Get comment location and verify it starts at the beginning of the line
    this.hasLocationInfo(sourceFilePath, beginLine, _, endLine, endColumn) and
    beginColumn = 1
  }
}