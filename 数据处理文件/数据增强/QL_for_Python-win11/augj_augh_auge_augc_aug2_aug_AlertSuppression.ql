/**
 * @name Alert suppression
 * @description Analyzes alert suppression mechanisms in Python code with detailed suppression logic
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for handling suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment processing utilities for analyzing comments
private import semmle.python.Comment as PyComment

/**
 * Represents AST nodes that support precise location tracking.
 */
class TrackedAstNode instanceof PyComment::AstNode {
  /**
   * Checks if the node's location matches the specified coordinates.
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Returns a string representation of the AST node.
   */
  string toString() { result = super.toString() }
}

/**
 * Represents single-line comments with detailed location tracking capabilities.
 */
class TrackedSingleLineComment instanceof PyComment::Comment {
  /**
   * Determines if the comment's location matches the provided coordinates.
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /**
   * Retrieves the textual content of the comment.
   */
  string getText() { result = super.getContents() }

  /**
   * Returns a string representation of the comment.
   */
  string toString() { result = super.toString() }
}

// Establish suppression relationship using the provided template
import AlertSuppUtil::Make<TrackedAstNode, TrackedSingleLineComment>

/**
 * A suppression comment that follows the noqa standard. This is recognized by both pylint and pyflakes,
 * and should also be respected by lgtm.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof TrackedSingleLineComment {
  /**
   * Constructs a NoqaSuppressionComment by matching the noqa pattern.
   */
  NoqaSuppressionComment() {
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the annotation identifier for this suppression.
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the scope of the suppression annotation.
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Check that the comment is at the beginning of the line and matches the location
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}