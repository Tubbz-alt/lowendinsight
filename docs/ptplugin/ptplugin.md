# Project Type Plugins

Interface for adding support for detecting project types and processing
information from their individual configuration files. This is done by providing
a plugin module in the `plugins/` folder with the language name followed by
`_plugin.ex` (_the module name is CamelCased_).

## Plugin Requirements

The plugin must provide and make these functions public.

- `is_filetype(PtPlugin.dir_struct) :: boolean()`
    : Returns `true` if the the files provided in the input indicate that the
    project is for that file type.

- `get_project_type(PtPlugin.dir_struct) :: String.t`
    : Returns a string with the name of the tool used to manage the project
    (_e.g. Maven, Gradle_).

- _More to be announced..._
