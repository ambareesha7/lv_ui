defmodule LvUiWeb.Live.PdfLive do
  require Logger
  use LvUiWeb, :live_view
  alias Phoenix.LiveView.AsyncResult

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))
     |> assign(initial: true)
     |> assign(:pdf_viewer, AsyncResult.loading())}
  end

  def handle_event("pdf:" <> type = _event, _params, socket) do
    {:noreply,
     socket
     |> assign(pdf_viewer: AsyncResult.loading(), initial: false)
     |> start_async(:pdf, fn -> generate_pdf(type) end)}
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Anything: #{inspect(params)}")}
  end

  def handle_async(:pdf, {:ok, {:ok, type}}, socket) do
    %{pdf_viewer: pdf_viewer} = socket.assigns

    {:noreply, assign(socket, :pdf_viewer, AsyncResult.ok(pdf_viewer, type))}
  end

  def generate_pdf(type) do
    file = generate_typst(type)

    path = Path.relative("priv/static/images/")
    {_, res} = System.cmd("typst", ["compile", "assets/#{file}", "#{path}template.pdf"])

    case res do
      0 ->
        {:ok, type}

      _ ->
        Logger.warning("unable to generate pdf error code: #{inspect(res)}")
        {:error, "unable to generate pdf"}
    end
  end

  def generate_typst(type) do
    case type do
      "report" ->
        file_name = "template.typ"
        # create typst file
        File.write!("assets/#{file_name}", template(100))
        file_name

      _ ->
        "proposal.typ"
    end
  end

  def template(num_of_employees) do
    """
    #align(right)[Date:
    #datetime.today().display()]
    #align(center)[= Current Employees]

    This is a report showing the company's current employees.

    #table(
      columns: (auto, 1fr, auto, auto),
      [*No*], [*Name*], [*Salary*], [*Age*],
      #{table_content(build_employees(num_of_employees))}
    )
    """
  end

  defp table_content(columns) when is_list(columns) do
    Enum.map_join(columns, ",\n  ", fn row ->
      Enum.map_join(row, ", ", &format_column_element/1)
    end)
  end

  def build_employees(n) do
    for n <- 1..n do
      name = "#{Faker.Person.first_name()} #{Faker.Person.last_name()}"
      salary = "US $ #{Enum.random(1000..15_000) / 1}"
      [n, name, salary, Enum.random(16..60)]
    end
  end

  defp format_column_element(e) when is_integer(e) or is_binary(e), do: add_quotes(e)
  defp format_column_element(unknown), do: unknown |> inspect() |> add_quotes()

  defp add_quotes(s), do: "\"#{s}\""
end
