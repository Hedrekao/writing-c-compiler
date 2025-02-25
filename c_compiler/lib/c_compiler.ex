defmodule CCompiler do

  def start(_type, _args) do
    file_path = System.argv() |> Enum.at(0)
    _mode = System.argv() |> Enum.at(1)

    {result, data} = Lexer.lex(file_path)

    case result do
      :ok ->
        IO.inspect(data)
      :error ->
        IO.puts(:stderr, "Error: #{data}")
        System.halt(1)
    end

    {:ok, self()}
  end
end
