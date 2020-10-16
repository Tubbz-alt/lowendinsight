defmodule GitHelperTest do
  use ExUnit.Case
  doctest GitHelper

 @moduledoc """
 This will test various functions in git_helper. However, since most of these functions
 are private, in order to test them you will need to make them public. I have added
 a tag :helper to all tests so that you may include or uninclude them accordingly.

 TODO: confirm that count can't be misconstrued and push the value so analysis can still be done
 """

  setup_all do
    correct_atr = "John R Doe <john@example.com> (1):\n messages for commits"
    incorrect_e = "John R Doe <asdfoi@2> (1):\n messages for commits"
    e_with_semi = "John R Doe <asdfjk@l;> (1):\n messages for commits"
    name_with_num = "John 9 Doe <john@example.com> (10): \n amessages for commits"

    [
      correct_atr: correct_atr,
      incorrect_e: incorrect_e,
      e_with_semi: e_with_semi,
      name_with_num: name_with_num
    ]
  end

  setup do
    :ok
  end

  @tag :helper
  test "correct implementation", %{correct_atr: correct_atr} do
    assert {"John R Doe ", "john@example.com", "1"} = GitHelper.parse_header(correct_atr)
  end

  @tag :helper
  test "incorrect email", %{incorrect_e: incorrect_e} do
    assert {"John R Doe ", "asdfoi@2", "1"} = GitHelper.parse_header(incorrect_e)
  end

  @tag :helper
  test "semicolon error", %{e_with_semi: e_with_semi} do
    assert {"Could not process", "Could not process", "Could not process"} = GitHelper.parse_header(e_with_semi)
  end

  @tag :helper
  test "number error", %{name_with_num: name_with_num} do
    assert {"John 9 Doe ", "john@example.com", "10"} = GitHelper.parse_header(name_with_num)
  end
end