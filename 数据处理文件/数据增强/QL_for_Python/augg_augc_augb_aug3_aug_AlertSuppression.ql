/**
 * @name Alert Suppression Information
 * @description Provides comprehensive details about alert suppressions in the codebase, focusing on 'noqa' directive usage.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling module
private import semmle.python.Comment as P

// Represents AST nodes equipped with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Determine if the node's location matches the provided coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Provide a string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments that include location information
class SingleLineComment instanceof P::Comment {
  // Verify if the comment's location matches the given coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Obtain the text content of the comment
  string getText() { result = super.getContents() }

  // Return a string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template with custom node types
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a suppression comment using the 'noqa' directive. This directive is recognized by both pylint and pyflakes, and thus should be respected by LGTM as well.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor: identify comments that match the noqa pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provide the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Specify the code coverage scope for this suppression
  override predicate covers(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Retrieve the location details of the comment
    exists(int commentStartLine, int commentEndLine, int commentEndColumn |
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndColumn) and
      // Set the coverage to the entire line where the comment appears
      beginLine = commentStartLine and
      finishLine = commentEndLine and
      beginColumn = 1 and
      finishColumn = commentEndColumn
    )
  }
}