defmodule LvUiWeb.Live.FormLive do
  require Logger
  use LvUiWeb, :live_view

  def mount(_params, _session, socket) do
    form = to_form(%{})

    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))
     |> assign(form: form)}
  end

  def handle_event("form_changes", params, socket) do
    Process.send_after(self(), :clear_flash, 3000)
    Logger.warning(inspect(params))

    {:noreply,
     socket
     |> put_flash(:info, "form_changes: #{inspect(params)}")}
  end

  def handle_event("form_submit", params, socket) do
    Logger.warning(inspect(params))

    {:noreply,
     socket
     |> put_flash(:info, "form_submit: #{inspect(params)}")}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
