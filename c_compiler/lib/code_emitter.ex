defmodule CodeEmitter do

  def emit(program, file) do
    code =  emit_program(program)
    output_file = Path.rootname(file) <> ".s"

    try do
      File.write!(output_file, code)
      {:ok}
    rescue
      e -> {:error, e}
    end
  end

  defp emit_program({:program, function}) do
    assembly_code = emit_function(function)
    assembly_code = assembly_code <> ".section .note.GNU-stack,\"\",@progbits\n"
    assembly_code
  end

  defp emit_function({:function, name, instructions}) do
    code = "  .globl #{name}\n"
    code = code <> "#{name}:\n"
    code = code <> Enum.join(Enum.map(instructions, &emit_instruction/1), "\n")
    code = code <> "\n"

    code
  end

  defp emit_instruction({:mov, src, dst}) do
    src_code =
      case src do
        {:reg} -> "%eax"
        {:imm, imm} -> "$#{imm}"
      end

    dst_code =
      case dst do
        {:reg} -> "%eax"
        {:imm, imm} -> "$#{imm}"
      end

    "  mov #{src_code}, #{dst_code}"
  end

  defp emit_instruction({:ret}) do
    "  ret"
  end
end
