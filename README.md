# ExampleTestToolbox

We insert block comments with runnable examples in the isetbio and isetcam code.  The methods here read those examples and try to execute the code, reporting on errors.

The main program is RunExample() which takes either a function or a directory as an argument.  That function determines whether the input is a file or a directory and then invokes the function ExecuteExamplesInFunction or ExecuteExamplesInDirectory.

