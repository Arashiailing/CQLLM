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
// This class extends the basic AST node to provide standardized location information
class AstNode instanceof P::AstNode {
  // Determine if this node has specific location information
  // This predicate provides consistent location tracking across all AST nodes
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Extract location details from the parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  // Retrieve string representation of the AST node
  // This provides a consistent way to display node information
  string toString() { result = super.toString() }
}

// Represents a single-line Python comment with location and content tracking
// This class extends the basic comment to provide standardized location and content access
class SingleLineComment instanceof P::Comment {
  // Determine if this comment has specific location information
  // This predicate provides consistent location tracking for all comments
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Extract location details from the parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, finishLine, finishColumn)
  }

  // Retrieve the text content of the comment
  // This provides direct access to the comment's text without formatting
  string getText() { result = super.getContents() }

  // Retrieve string representation of the comment
  // This provides a consistent way to display comment information
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
// This import creates the necessary relationships for alert suppression functionality
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents a noqa-style suppression comment that can suppress alerts
// This class identifies and handles noqa comments, which are widely used in Python
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by verifying the comment matches the noqa pattern
  // This constructor ensures only valid noqa comments are considered for suppression
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix or error codes
    // The regex pattern matches "noqa" with optional content following it
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Retrieve the annotation identifier for this suppression mechanism
  // This identifies the tool or system that respects this suppression
  override string getAnnotation() { result = "lgtm" }

  // Define the code range covered by this suppression comment
  // This determines which parts of the code are affected by the suppression
  override predicate covers(
    string filePath, int startLine, int startColumn, int finishLine, int finishColumn
  ) {
    // Get comment location and verify it starts at the beginning of the line
    // Noqa comments typically suppress warnings on the line they appear on
    this.hasLocationInfo(filePath, startLine, _, finishLine, finishColumn) and
    startColumn = 1
  }
}