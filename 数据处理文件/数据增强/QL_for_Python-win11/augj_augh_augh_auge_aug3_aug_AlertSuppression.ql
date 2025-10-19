/**
 * @name Alert Suppression Information
 * @description Identifies and analyzes alert suppression mechanisms in Python codebases, 
 *              focusing on noqa-style comments that disable warnings.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents AST nodes with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Determine if node matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginCol, concludeLine, concludeCol)
  }

  // Return string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking
class SingleLineComment instanceof P::Comment {
  // Determine if comment matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFilePath, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, beginLine, beginCol, concludeLine, concludeCol)
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

  // Extract location details from comment
  private predicate commentLocation(
    string sourceFilePath, int commentStartLine, int commentEndLine, int commentEndCol
  ) {
    this.hasLocationInfo(sourceFilePath, commentStartLine, _, commentEndLine, commentEndCol)
  }

  // Define code coverage scope for this suppression
  override predicate covers(
    string sourceFilePath, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    exists(int commentStartLine, int commentEndLine, int commentEndCol |
      this.commentLocation(sourceFilePath, commentStartLine, commentEndLine, commentEndCol) and
      // Match coverage boundaries to comment location
      beginLine = commentStartLine and
      concludeLine = commentEndLine and
      beginCol = 1 and
      concludeCol = commentEndCol
    )
  }
}