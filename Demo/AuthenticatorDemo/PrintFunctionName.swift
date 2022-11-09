/// Calls `print` to log the name of the function from which it's called.
///
/// Useful during logs-based-debugging to leave breadcrumbs.
func printFunctionName(_ name: StaticString = #function) {
    print(name)
}
