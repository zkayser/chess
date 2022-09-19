defimpl Inspect, for: Chess.Board do
  import Inspect.Algebra

  alias Chess.Piece

  def inspect(board, opts) do
    as_list = :array.to_list(board.grid)

    grid =
      as_list
      |> Stream.with_index()
      |> Enum.reduce([], fn {piece, index}, grid ->
        doc =
          case piece do
            nil ->
              "   "
              |> string()
              |> color(
                :binary,
                Inspect.Opts.new(syntax_colors: [binary: background_color(rem(index, 2))])
              )

            %Piece{} ->
              piece
              |> inspect()
              |> string()
              |> color(
                :binary,
                Inspect.Opts.new(syntax_colors: [binary: background_color(rem(index, 2))])
              )
          end

        [doc | grid]
      end)
      |> Enum.reverse()
      |> Enum.chunk_every(8)
      |> Enum.map(&concat/1)

    container_doc(
      "#Board<\n",
      grid,
      string("\n>"),
      opts,
      fn doc, _opts -> doc end,
      separator: "\n",
      break: :strict
    )
  end

  defp background_color(0), do: :light_black_background
  defp background_color(_), do: :light_blue_background
end
