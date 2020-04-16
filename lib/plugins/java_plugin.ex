# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule JavaPlugin do
  @moduledoc """
  Project-Type Plugin Interface

  To determine what type of project the target is and how to perform certain
  types of actions with the specified project type.
  """

  @doc """
    is_filetype/1 Uses the provided list of files in a directory to
    determine if the project relates to this filetype.
  """
  @spec is_filetype(PtPlugin.dir_struct) :: boolean()
  def is_filetype({rootpath, files}) do
    relfiles = for file <- files, do: Path.relative_to(file, rootpath)
    cond do
      _is_maven_project(relfiles) -> true
      _is_gradle_project(relfiles) -> true
      true -> false
    end
  end

  @doc """
    get_project_type/1 Uses the provided list of files in a directory to
    determine what the project managment tool the project uses.
  """
  @spec get_project_type(PtPlugin.dir_struct) :: String.t
  def get_project_type({rootpath, files}) do
    relfiles = for file <- files, do: Path.relative_to(file, rootpath)
    cond do
      _is_maven_project(relfiles) -> "Maven"
      _is_gradle_project(relfiles) -> "Gradle"
      true -> ""
    end
  end

  @spec _is_maven_project(Path.t) :: boolean()
  defp _is_maven_project(relfiles) do
    # Depends on the fact that pom.xml must be in the project root
    Enum.member?(relfiles, "pom.xml")
  end

  @spec _is_gradle_project(Path.t) :: boolean()
  defp _is_gradle_project(relfiles) do
    # Depends on the fact that build.gradle must be in the project root
    Enum.member?(relfiles, "build.gradle")
  end
end

