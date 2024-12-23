import Bitwise

defmodule P1 do
  def evolve(number) do
    one = bxor(number <<< 6, number) &&& 0xFFFFFF
    two = bxor(one >>> 5, one) &&& 0xFFFFFF
    bxor(two <<< 11, two) &&& 0xFFFFFF
  end

  def evolve(secret, i) do
    if i <= 0 do
      secret
    else
      evolve(evolve(secret), i-1)
    end
  end

  def line_to_number(line) do
    {i, _} = Integer.parse(line)
    i
  end
end

argv = System.argv()
if length(argv) < 1 do
  IO.puts("No file included!")
  System.halt(1)
end

argv
  |> List.first() # fp
  |> File.read!() # contents
  |> String.split() # lines
  |> Enum.map(fn x -> P1.line_to_number(x) end) # numbers
  |> List.foldl(0, fn x, acc -> acc + P1.evolve(x, 2000) end) # sum
  |> IO.puts()
