/**
 * @name Alert suppression
 * @description Provides functionality for analyzing and handling alert suppressions in code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AlertUtil
// Import Python comment processing module
private import semmle.python.Comment as PyComment

// Represents AST nodes with location tracking capabilities
class AstNode instanceof PyComment::AstNode {
  // Determine if node's location matches the specified coordinates
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginCol, int finishLine, int finishCol
  ) {
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginCol, finishLine, finishCol)
  }

  // Provide string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof PyComment::Comment {
  // Check if comment's location matches the specified coordinates
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginCol, int finishLine, int finishCol
  ) {
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginCol, finishLine, finishCol)
  }

  // Extract the text content of the comment
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AlertUtil template
import AlertUtil::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. This comment style is recognized by both pylint and pyflakes,
 * and therefore should also be respected by lgtm.
 */
// Represents noqa-style suppression comments
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by identifying noqa comment pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the code coverage scope for this suppression
  override predicate covers(
    string sourcePath, int beginLine, int beginCol, int finishLine, int finishCol
  ) {
    // Match comment location and enforce line-start position
    this.hasLocationInfo(sourcePath, beginLine, _, finishLine, finishCol) and
    beginCol = 1
  }
}