defmodule Assembler do

  def parse_program({:program, function_def}) do
    function = parse_function(function_def)
    Assembly.Program.new(function)
  end

  defp parse_function({_, name_ident, body}) do
    {_, name} = name_ident
    instructions = parse_instructions(body)
    Assembly.Function.new(name, instructions)
  end

  defp parse_instructions({:return, expression}) do
    instructions = []
    operand = parse_operand(expression)
    instructions = [Assembly.Instruction.mov(operand, Assembly.Operand.reg()) | instructions]
    instructions = [Assembly.Instruction.ret() | instructions]

    Enum.reverse(instructions)
  end

  defp parse_operand({:constant, value}) do
    Assembly.Operand.imm(value)
  end

end
