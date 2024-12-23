import Bitwise

defmodule P2 do
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

  def evolve_history_mod10(secret, i) do
    evolve_history_mod10(secret, i, [rem(secret, 10)])
  end

  def evolve_history_mod10(secret, i, history) do
    if i <= 0 do
      history
    else
      next = evolve(secret)
      evolve_history_mod10(next, i-1, history ++ [rem(next, 10)])
    end
  end

  def get_changes_from_history(history) do
    history
      |> Enum.zip(Enum.drop(history, 1))
      |> Enum.reject(fn {_, b} -> b == nil end)
      |> List.foldl([], fn {a, b}, acc -> acc ++ [b-a] end)
  end

  def map_change_windows_to_revenue(changes, history) do
    [
      Enum.drop(history, 4),
      changes,
      Enum.drop(changes, 1),
      Enum.drop(changes, 2),
      Enum.drop(changes, 3)
    ]
      |> Enum.zip()
      |> Enum.reject(fn {_, _, _, _, d} -> d == nil end)
      |> List.foldl(
        %{},
        fn {h, a, b, c, d}, acc ->
          # ignore subsequent instances of the same sequence
          if Map.has_key?(acc, {a, b, c, d}) do
            acc
          else
            Map.put(acc, {a, b, c, d}, h)
          end
        end
      )
  end

  def get_window_score(windows_list, sequence) do
    get_window_score(windows_list, sequence, 0)
  end

  def get_window_score([], _, sum) do
    sum
  end

  def get_window_score([windows_to_revenue|rest], sequence, sum) do
    get_window_score(rest, sequence, sum + Map.get(windows_to_revenue, sequence, 0))
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

histories = argv
  |> List.first() # fp
  |> File.read!() # contents
  |> String.split() # lines
  |> Enum.map(fn x -> P2.line_to_number(x) end) # numbers
  |> Enum.map(fn x -> P2.evolve_history_mod10(x, 2000) end)
changes = histories
  |> Enum.map(fn h -> P2.get_changes_from_history(h) end)
windows_list = [changes, histories]
  |> Enum.zip_with(fn [c, h] -> P2.map_change_windows_to_revenue(c, h) end)
windows_list
  |> Enum.map(fn windows_to_revenue -> Map.keys(windows_to_revenue) end) # keys
  |> List.foldl(MapSet.new(), fn k, acc -> MapSet.union(acc, MapSet.new(k)) end)
  |> Enum.map(fn s -> P2.get_window_score(windows_list, s) end)
  |> Enum.max()
  |> IO.puts()
