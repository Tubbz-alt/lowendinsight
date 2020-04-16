# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule PtPlugin do
  @moduledoc """
  Project-Type Plugin Interface

  To determine what type of project the target is and how to perform certain
  types of actions with the specified project type.
  """

  # Type specification for a rootpath-filelist pair that can be passed into the
  # plugin functions. The rootpath part specifies the project root directory.
  @type dir_struct :: {Path.t, [Path.t]}

  @doc """
    list_plugins/0 Get a current listing of supported project type plugins.
  """
  @spec list_plugins :: [String.t]
  def list_plugins() do
    Map.keys(get_plugins())
  end

  @doc """
    get_plugins/0 Get a list of supported plugins in a map with the keys being
    filetypes and values being the plugin path.
  """
  @spec get_plugins() :: %{String.t => String.t}
  def get_plugins() do
    list =
      for plugin <- 'plugins/*_plugin.ex' |> Path.expand(__DIR__) |> Path.wildcard() do
        base = Path.basename(plugin)
        type = Regex.replace(~r/(\w+)_plugin\.ex/, base, "\\g{1}")
        {type, plugin}
      end
    Enum.into(list, %{})
  end

  @doc """
    assert_project_filetype/2 Checks the project against the specified
    filetype, returns True if the filetype matches or False if it doesn't. It
    returns :ok if the check was good (positive or negative), :error if the
    filetype is not listed in the list of plugins.
  """
  @spec assert_project_filetype(dir_struct, String.t) :: {:ok | :error, boolean()}
  def assert_project_filetype(files, filetype) do
    if Enum.member?(list_plugins(), filetype) == false do
      {:error, false}
    else
      {ret, _} = Code.eval_string(_is_filetype_string(filetype), [files: files])
      {:ok, ret}
    end
  end
  @spec _is_filetype_string(String.t) :: String.t
  defp _is_filetype_string(filetype) do
    Macro.camelize(filetype) <> "Plugin.is_filetype( files )"
  end

  @doc """
    get_project_filetype/1 Tries to detect the project filetype by iterating
    through the known types and checking the listed files in the project.
  """
  @spec get_project_filetype(dir_struct) :: {:ok | :error, String.t}
  def get_project_filetype(files) do
    _get_project_filetype(files, list_plugins())
  end
  defp _get_project_filetype({_rootpath, files}, []) do
    {:error, Enum.join(files, " ")}
  end
  defp _get_project_filetype(files, types) do
    case assert_project_filetype(files, hd(types)) do
      {:error, _} -> {:error, ""}
      {:ok, true} -> {:ok, hd(types)}
      {:ok, false} -> _get_project_filetype(files, tl(types))
    end
  end

  @doc """
    list_tree/1 Lists all files in the provided directory. Returns the result
    with a keyword map of the root path and then the list of files.
  """
  @spec list_tree(Path.t) :: dir_struct
  def list_tree(filepath) do
    tree = _list_tree(filepath)
    {filepath, tree}
  end
  defp _list_tree(filepath) do
    cond do
      String.contains?(filepath, ".git") -> []
      true -> _expand(File.ls(filepath), filepath)
    end
  end
  defp _expand({:ok, files}, path) do
    files
    |> Enum.flat_map(&_list_tree(Path.join(path,"#{&1}")))
  end
  defp _expand({:error, _}, path) do
    [path]
  end

end
