defmodule LiveArtWeb.GlobalComponents do
  alias LiveArtWeb.Core

  defmacro __using__(_) do
    quote do
      import Core.Back
      import Core.Button
      import Core.Error
      import Core.FlashGroup
      import Core.Flash
      import Core.Header
      import Core.Icon
      import Core.Input
      import Core.Label
      import Core.List
      import Core.Modal
      import Core.SimpleForm
      import Core.Table
    end
  end
end
