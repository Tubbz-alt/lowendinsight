# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule PtPluginTest do
  use ExUnit.Case
  doctest PtPlugin

  setup_all do
    [
      key: "value"
    ]
  end

  setup do
    # Empty for now
    :ok
  end

  test "Get a list of plugins" do
    plugins = PtPlugin.list_plugins()
    assert 1 <= length(plugins)
    assert true == Enum.member?(plugins, "java")
  end

  test "Make sure all plugins have required functions" do
    plugins = PtPlugin.list_plugins()
    requiredFunctions = [
      :is_filetype,
      :get_project_type,
    ]
    for plugin <- plugins do
      getModFuncs = Macro.camelize(plugin) <> "Plugin.__info__(:functions)"
      {modFuncsKw, _other} = Code.eval_string(getModFuncs)
      modFuncs = Enum.into(modFuncsKw, %{})
      for func <- requiredFunctions do
        assert true == Enum.member?(Map.keys(modFuncs), func)
      end
    end
  end

  test "Assert Filetypes" do
    status = PtPlugin.assert_project_filetype({'.', ['./app/__init__.py']}, "java")
    assert {:ok, false} == status
    status = PtPlugin.assert_project_filetype({'.', ['./pom.xml']}, "java")
    assert {:ok, true} == status
  end

  test "Assert Filetype Failure" do
    status = PtPlugin.assert_project_filetype({'.', ['./pom.xml']}, "bad")
    assert {:error, false} == status
  end

  test "Detect filetype by iteration" do
    status = PtPlugin.get_project_filetype({'.', ['./pom.xml']})
    assert {:ok, "java"} == status
    {statuscode, _str} = PtPlugin.get_project_filetype({'.', ['./somefile.txt']})
    assert :error == statuscode
  end

  test "Test detect on example projects" do
    projdir = "../" |> Path.expand(__DIR__)
    tree = PtPlugin.list_tree(projdir)
    {statuscode, _str} = PtPlugin.get_project_filetype(tree)

    assert :error == statuscode
  end
end
