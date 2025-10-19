/**
 * @name Alert suppression
 * @description Identifies and processes alert suppressions within Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents an AST node with location tracking capabilities
class LocatableAstNode instanceof P::AstNode {
  // Verify if node location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Provide string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents a single-line comment with location tracking
class LocatableComment instanceof P::Comment {
  // Verify if comment location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Retrieve the text content of the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<LocatableAstNode, LocatableComment>

/**
 * Represents a noqa-style suppression comment. Both pylint and pyflakes 
 * recognize this annotation, making it compatible with lgtm as well.
 */
class NoqaStyleSuppression extends SuppressionComment instanceof LocatableComment {
  // Initialize by matching noqa comment patterns
  NoqaStyleSuppression() {
    LocatableComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the identifier for this suppression annotation
  override string getAnnotation() { result = "lgtm" }

  // Define the code coverage scope for this suppression
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Extract and validate comment location information
    exists(int cmtStartLine, int cmtEndLine, int cmtEndColumn |
      this.hasLocationInfo(filePath, cmtStartLine, _, cmtEndLine, cmtEndColumn) and
      // Configure line boundaries and position matching
      startLine = cmtStartLine and
      endLine = cmtEndLine and
      startCol = 1 and
      endCol = cmtEndColumn
    )
  }
}