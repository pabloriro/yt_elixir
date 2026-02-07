defmodule CreatorPulseWeb.PageController do
  use CreatorPulseWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
