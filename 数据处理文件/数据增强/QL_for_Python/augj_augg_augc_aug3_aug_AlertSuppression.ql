/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtils
// Import Python comment processing module
private import semmle.python.Comment as PythonCommentUtils

// Represents AST nodes with location information
class AstNode instanceof PythonCommentUtils::AstNode {
  // Validate node location matches specified coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Return string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof PythonCommentUtils::Comment {
  // Validate comment location matches specified coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Retrieve comment text content
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AlertSuppressionUtils template
import AlertSuppressionUtils::Make<AstNode, SingleLineComment>

/**
 * Represents a 'noqa' suppression comment. Recognized by both pylint and pyflakes,
 * and therefore should be supported by LGTM.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa comment pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string sourceFilePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Extract location boundaries from comment
    exists(int startLine, int endLine, int endColumn |
      // Get comment's location details
      this.hasLocationInfo(sourceFilePath, startLine, _, endLine, endColumn) and
      // Set coverage boundaries to match comment line
      beginLine = startLine and
      finishLine = endLine and
      beginColumn = 1 and
      finishColumn = endColumn
    )
  }
}