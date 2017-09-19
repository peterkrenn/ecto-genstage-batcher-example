defmodule EB.User.Loader do
  def load(id) do
    GenServer.cast(EB.User.Loader.Producer, {:load, id, self()})
  end
end
