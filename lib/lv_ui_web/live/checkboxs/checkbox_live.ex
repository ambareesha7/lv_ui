defmodule LvUiWeb.Live.CheckboxLive do
  use LvUiWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))
     |> assign(form: to_form(%{"bike" => nil, "car" => nil, "boat" => nil, "house" => nil}))}
  end

  def render(assigns) do
    ~H"""
    <%!-- check box's --%>
    <div class="flex justify-center">
      <.form for={@form} phx-submit="create_assets" class="flex flex-col  bg-gray-100 p-5">
        <.button type="reset" value="Uncheck all">
          Uncheck all
        </.button>
        <h5 class="pb-2 pt-4">I have these assets</h5>
        <div :for={{name, value} <- @form.params}>
          <.input type="checkbox" id={name} name={name} value={value} label={name} />
        </div>
        <.button type="submit" class="mt-5">submit</.button>
      </.form>
    </div>
    """
  end

  def handle_event("create_assets", params, socket) do
    {:noreply, socket |> put_flash(:info, "received-items: #{inspect(params)}")}
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Anything: #{inspect(params)}")}
  end
end
