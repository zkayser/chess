defimpl Inspect, for: Chess.Board do
  import Inspect.Algebra

  alias Chess.Piece

  def inspect(board, opts) do
    as_list = :array.to_list(board.grid)

    grid =
      as_list
      |> Enum.reduce([], fn piece, grid ->
        doc =
          case piece do
            nil ->
              string(" x ")

            %Piece{} ->
              string(inspect(piece))
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
end
