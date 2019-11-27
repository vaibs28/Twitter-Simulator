defmodule Proj4 do
  use Application

  def start(_type, _args) do
    [num_user, num_msg] = Enum.map(System.argv(), fn x -> String.to_integer(x) end)
    pid = Simulator.start_link(num_user, num_msg)
    {:ok, pid}
  end
end
