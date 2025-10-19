/**
 * @name Alert suppression
 * @description Identifies alert suppression patterns in Python code using noqa comments.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

/**
 * Provides location tracking for AST nodes. This class extends the base AST node
 * to include location information capabilities.
 */
class AstNode instanceof P::AstNode {
  /**
   * Holds if this node has the specified location coordinates.
   * @param sourceFile The file path of the node
   * @param beginLine The starting line number
   * @param beginColumn The starting column number
   * @param finishLine The ending line number
   * @param finishColumn The ending column number
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, finishLine, finishColumn)
  }

  /**
   * Gets a string representation of this node.
   * @return The string representation
   */
  string toString() { result = super.toString() }
}

/**
 * Represents single-line comments with location tracking capabilities. This class
 * extends the base comment class to provide location information.
 */
class SingleLineComment instanceof P::Comment {
  /**
   * Holds if this comment has the specified location coordinates.
   * @param sourceFile The file path of the comment
   * @param beginLine The starting line number
   * @param beginColumn The starting column number
   * @param finishLine The ending line number
   * @param finishColumn The ending column number
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, finishLine, finishColumn)
  }

  /**
   * Gets the text content of this comment.
   * @return The comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Gets a string representation of this comment.
   * @return The string representation
   */
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this syntax,
 * making it compatible with LGTM alerts.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Creates a NoqaSuppressionComment by matching the noqa comment pattern.
   * The pattern matches comments containing "noqa" (case-insensitive).
   */
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Gets the suppression annotation identifier.
   * @return The annotation identifier "lgtm"
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code coverage scope for this suppression. The suppression covers
   * the entire line where the comment appears.
   * @param sourceFile The file path
   * @param beginLine The starting line number
   * @param beginColumn The starting column number
   * @param finishLine The ending line number
   * @param finishColumn The ending column number
   */
  override predicate covers(
    string sourceFile, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Extract location details from comment
    exists(int startLine, int endLine, int endColumn |
      // Get comment's location boundaries
      this.hasLocationInfo(sourceFile, startLine, _, endLine, endColumn) and
      // Set coverage to match the entire line
      beginLine = startLine and
      finishLine = endLine and
      beginColumn = 1 and
      finishColumn = endColumn
    )
  }
}