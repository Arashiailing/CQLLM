/**
 * @name Alert suppression
 * @description Identifies and processes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import the CodeQL library for handling alert suppression functionality
private import codeql.util.suppression.AlertSuppression as AlertSupp
// Import the CodeQL module for processing Python comments
private import semmle.python.Comment as PyComment

// Defines a class representing AST nodes that can be tracked by their source location
class AstNode instanceof PyComment::AstNode {
  // Determines if the node's location matches the specified file path and coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Provides a textual representation of the AST node
  string toString() { result = super.toString() }
}

// Defines a class representing single-line comments with location tracking capabilities
class SingleLineComment instanceof PyComment::Comment {
  // Determines if the comment's location matches the specified file path and coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Retrieves the textual content of the comment
  string getText() { result = super.getContents() }

  // Provides a textual representation of the comment
  string toString() { result = super.toString() }
}

// Creates the suppression relationship framework using the AlertSupp template
import AlertSupp::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Defines a class for handling noqa-style suppression comments commonly used in Python
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that identifies comments matching the noqa pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Specifies the annotation identifier for this suppression type
  override string getAnnotation() { result = "lgtm" }

  // Defines the scope of code that this suppression comment covers
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    exists(int commentStartLine, int commentEndLine, int commentEndColumn |
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndColumn) and
      // Ensure the suppression covers from the beginning of the line to the comment's end
      startLine = commentStartLine and
      endLine = commentEndLine and
      startColumn = 1 and
      endColumn = commentEndColumn
    )
  }
}