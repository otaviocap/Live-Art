defmodule LiveArtWeb.GlobalCommands do
  alias LiveArtWeb.Commands

  defmacro __using__(_) do
    quote do
      import Commands.Display
      import Commands.Error
      import Commands.Modal
    end
  end
end
