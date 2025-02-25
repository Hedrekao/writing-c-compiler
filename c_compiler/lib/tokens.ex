defmodule Tokens do
  @type t ::
            {:identifier, String.t()}
          | {:constant, number()}
          | :int
          | :return
          | :void
          | :open_parenthesis
          | :close_parenthesis
          | :open_brace
          | :close_brace
          | :semicolon

  def token(:identifier, value), do: {:identifier, value}
  def token(:constant, value), do: {:constant, value}
  def token(:int), do: {:int, "int"}
  def token(:return), do: {:return, "return"}
  def token(:void), do: {:void, "void"}
  def token(:open_parenthesis), do: {:open_parenthesis}
  def token(:close_parenthesis), do: {:close_parenthesis}
  def token(:open_brace), do: {:open_brace}
  def token(:close_brace), do: {:close_brace}
  def token(:semicolon), do: {:semicolon}
end
