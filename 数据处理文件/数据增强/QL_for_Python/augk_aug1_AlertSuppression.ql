/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities
private import semmle.python.Comment as P

/**
 * Represents a Python AST node with location tracking capabilities.
 * Provides unified location information interface for AST nodes.
 */
class AstNode instanceof P::AstNode {
  /**
   * Determines if the node has specific location information.
   * @param filePath - Path of the source file
   * @param startLine - Starting line number
   * @param startColumn - Starting column number
   * @param endLine - Ending line number
   * @param endColumn - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Validate location against parent class location data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Returns string representation of the AST node */
  string toString() { result = super.toString() }
}

/**
 * Represents a single-line Python comment with location tracking.
 * Extends base comment functionality with location interface.
 */
class SingleLineComment instanceof P::Comment {
  /**
   * Determines if the comment has specific location information.
   * @param filePath - Path of the source file
   * @param startLine - Starting line number
   * @param startColumn - Starting column number
   * @param endLine - Ending line number
   * @param endColumn - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Validate location against parent class location data
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Retrieves the text content of the comment */
  string getText() { result = super.getContents() }

  /** Returns string representation of the comment */
  string toString() { result = super.toString() }
}

// Generate suppression relationships between AST nodes and comments
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * Implements suppression logic for noqa-style comments.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /** Initializes by verifying comment matches noqa pattern */
  NoqaSuppressionComment() {
    // Match case-insensitive noqa with optional suffix
    super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns the annotation identifier for this suppression */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression.
   * @param filePath - Path of the source file
   * @param startLine - Starting line number
   * @param startColumn - Starting column number
   * @param endLine - Ending line number
   * @param endColumn - Ending column number
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Retrieve comment location and verify it starts at column 1
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}