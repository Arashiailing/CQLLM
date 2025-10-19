/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

/**
 * Represents AST nodes with location tracking capabilities.
 * This class extends the base AST node to provide location information.
 */
class AstNode instanceof P::AstNode {
  /**
   * Determines if the node matches the specified location coordinates.
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
   * Returns a string representation of the node.
   * @return The string representation
   */
  string toString() { result = super.toString() }
}

/**
 * Represents single-line comments with location tracking capabilities.
 * This class extends the base comment class to provide location information.
 */
class SingleLineComment instanceof P::Comment {
  /**
   * Determines if the comment matches the specified location coordinates.
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
   * Retrieves the text content of the comment.
   * @return The comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Returns a string representation of the comment.
   * @return The string representation
   */
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * This class represents comments that suppress alerts using the noqa syntax.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructs a NoqaSuppressionComment by matching the noqa comment pattern.
   * The pattern matches comments containing "noqa" (case-insensitive).
   */
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the suppression annotation identifier.
   * @return The annotation identifier "lgtm"
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code coverage scope for this suppression.
   * The suppression covers the entire line where the comment appears.
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
    exists(int commentStartLine, int commentEndLine, int commentEndColumn |
      // Get comment's location boundaries
      this.hasLocationInfo(sourceFile, commentStartLine, _, commentEndLine, commentEndColumn) and
      // Set coverage to match the entire line
      beginLine = commentStartLine and
      finishLine = commentEndLine and
      beginColumn = 1 and
      finishColumn = commentEndColumn
    )
  }
}