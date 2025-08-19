# Relative Path Normalization

Dispatcher actions accept a `RelativePath` argument that points to the project root relative to the working directory. Before invoking adapter functions, the dispatcher normalizes this value:

- trailing directory separators are removed
- `.` segments are resolved

Inputs such as `./` or `scripts/../` therefore become `.` and `scripts`. Normalization ensures all scripts receive consistent paths regardless of how callers format the argument.
