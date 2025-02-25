defmodule Assembly do
  defmodule Program do
    def new(function_definition), do: {:program, function_definition}
  end

  defmodule Function do
    def new(name, instructions), do: {:function, name, instructions}
  end

  defmodule Instruction do
    def ret(), do: {:ret}
    def mov(src, dst), do: {:mov, src, dst}
  end

  defmodule Operand do
    def reg(), do: {:reg}
    def imm(imm), do: {:imm, imm}
  end

end
