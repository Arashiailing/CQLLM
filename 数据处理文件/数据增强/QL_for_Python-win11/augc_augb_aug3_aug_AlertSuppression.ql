/**
 * @name Alert Suppression Information
 * @description Provides details about alert suppressions in the codebase.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling module
private import semmle.python.Comment as P

// Represents AST nodes that have location tracking capabilities
class AstNode instanceof P::AstNode {
  // Determine if the node's location matches the provided coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  // Provide a string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments that include location information
class SingleLineComment instanceof P::Comment {
  // Verify if the comment's location matches the given coordinates
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  // Obtain the text content of the comment
  string getText() { result = super.getContents() }

  // Return a string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a suppression comment using the 'noqa' directive. This directive is recognized by both pylint and pyflakes, and thus should be respected by LGTM as well.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Construct by identifying comments that match the noqa pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provide the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Specify the code coverage scope for this suppression
  override predicate covers(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Retrieve the location details of the comment
    exists(int cStartLine, int cEndLine, int cEndCol |
      this.hasLocationInfo(file, cStartLine, _, cEndLine, cEndCol) and
      // Set the coverage to the entire line where the comment appears
      startLine = cStartLine and
      endLine = cEndLine and
      startCol = 1 and
      endCol = cEndCol
    )
  }
}