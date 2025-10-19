/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents AST nodes with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Verify node location matches specified coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  // Provide string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location tracking and text content
class SingleLineComment instanceof P::Comment {
  // Verify comment location matches specified coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  // Retrieve the text content of the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
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
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract location details from comment
    exists(
      int suppressionStartLine, 
      int suppressionEndLine, 
      int suppressionEndCol
    |
      // Retrieve comment location information
      this.hasLocationInfo(
        file, 
        suppressionStartLine, 
        _, 
        suppressionEndLine, 
        suppressionEndCol
      ) and
      // Enforce line-start position and match boundaries
      startLine = suppressionStartLine and
      endLine = suppressionEndLine and
      startCol = 1 and
      endCol = suppressionEndCol
    )
  }
}