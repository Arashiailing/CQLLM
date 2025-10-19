/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import the AlertSuppression module from CodeQL utility library, aliased as AlertSuppressionModule
private import codeql.util.suppression.AlertSuppression as AlertSuppressionModule
// Import the Python comment processing module, aliased as PythonCommentModule
private import semmle.python.Comment as PythonCommentModule

/**
 * Represents a node in the Python AST (Abstract Syntax Tree).
 * This class extends the base AstNode from the Python comment module.
 */
class AstNode instanceof PythonCommentModule::AstNode {
  /**
   * Determines if this node has the specified location information.
   * @param filePath - The path of the file containing the node
   * @param startLine - The starting line number of the node
   * @param startColumn - The starting column number of the node
   * @param endLine - The ending line number of the node
   * @param endColumn - The ending column number of the node
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate to the parent class's getLocation method to check location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /**
   * Returns a string representation of this AST node.
   * @return A string describing the node
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a single-line comment in Python code.
 * This class extends the base Comment class from the Python comment module.
 */
class SingleLineComment instanceof PythonCommentModule::Comment {
  /**
   * Determines if this comment has the specified location information.
   * @param filePath - The path of the file containing the comment
   * @param startLine - The starting line number of the comment
   * @param startColumn - The starting column number of the comment
   * @param endLine - The ending line number of the comment
   * @param endColumn - The ending column number of the comment
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate to the parent class's getLocation method to check location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /**
   * Returns the text content of this comment.
   * @return The text of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Returns a string representation of this comment.
   * @return A string describing the comment
   */
  string toString() { result = super.toString() }
}

// Generate the suppression relationship between AstNode and SingleLineComment using the AlertSuppressionModule::Make template
import AlertSuppressionModule::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * This class extends SuppressionComment and SingleLineComment to handle noqa-style suppressions.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructs a NoqaSuppressionComment instance.
   * The comment text must match the noqa format pattern.
   */
  NoqaSuppressionComment() {
    // Check if the comment text matches the noqa pattern (case-insensitive)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the annotation identifier for this suppression comment.
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Determines the code range covered by this suppression comment.
   * @param filePath - The path of the file containing the covered code
   * @param startLine - The starting line number of the covered code
   * @param startColumn - The starting column number of the covered code (must be 1, i.e., line start)
   * @param endLine - The ending line number of the covered code
   * @param endColumn - The ending column number of the covered code
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Check the comment's location information and ensure it starts at the beginning of a line
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}