/**
 * @name Alert Suppression Information
 * @description Provides details about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents AST nodes with location tracking
class AstNode instanceof P::AstNode {
  // Check if node matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginCol, endLine, endCol)
  }

  // Return string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof P::Comment {
  // Check if comment matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginCol, endLine, endCol)
  }

  // Retrieve comment text content
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents noqa-style suppression comments
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize by matching noqa comment pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string filePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Extract location details from comment
    exists(int cmtStartLine, int cmtEndLine, int cmtEndCol |
      this.hasLocationInfo(filePath, cmtStartLine, _, cmtEndLine, cmtEndCol) and
      // Match coverage boundaries to comment location
      beginLine = cmtStartLine and
      endLine = cmtEndLine and
      beginCol = 1 and
      endCol = cmtEndCol
    )
  }
}