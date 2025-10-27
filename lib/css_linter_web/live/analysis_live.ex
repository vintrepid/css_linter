defmodule CssLinterWeb.Live.AnalysisLive do
  @moduledoc """
  LiveView for analyzing and displaying CSS class usage.
  
  This LiveView can be mounted in any Phoenix app by adding to your router:
  
      import CssLinterWeb.Router
      
      scope "/admin", MyAppWeb do
        pipe_through [:browser, :require_authenticated_user]
        
        css_linter_routes("/css-analysis")
      end
  
  Or mount directly:
  
      live "/css-analysis", CssLinterWeb.Live.AnalysisLive
  """
  
  use Phoenix.LiveView
  use LiveTable.LiveResource

  import Ecto.Query
  alias CssLinter.Schema.TailwindClassUsage

  def repo do
    Application.get_env(:css_linter, :repo) ||
      raise "css_linter repo not configured"
  end

  @impl true
  def mount(_params, _session, socket) do
    timestamps = TailwindClassUsage.available_timestamps()
    selected_timestamp = List.first(timestamps)
    analysis_summary = TailwindClassUsage.analysis_summary() || %{
      total_classes: 0,
      total_files: 0,
      total_usages: 0
    }
    projects = TailwindClassUsage.available_projects()
    selected_project = "all"

    socket =
      socket
      |> assign(:page_title, page_title())
      |> assign(:data_provider, {__MODULE__, :list_class_usage, []})
      |> assign(:selected_class, nil)
      |> assign(:available_timestamps, timestamps)
      |> assign(:selected_timestamp, selected_timestamp)
      |> assign(:analysis_summary, analysis_summary)
      |> assign(:show_run_form, false)
      |> assign(:run_description, "")
      |> assign(:available_projects, projects)
      |> assign(:selected_project, selected_project)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_timestamp", %{"timestamp" => timestamp}, socket) do
    {:ok, parsed_timestamp, _} = DateTime.from_iso8601(timestamp)
    
    socket =
      socket
      |> assign(:selected_timestamp, parsed_timestamp)
      |> assign(:selected_class, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_project", %{"project" => project}, socket) do
    socket =
      socket
      |> assign(:selected_project, project)
      |> assign(:selected_class, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_class", %{"class" => class_name}, socket) do
    {:noreply, assign(socket, :selected_class, class_name)}
  end

  @impl true
  def handle_event("close_details", _params, socket) do
    {:noreply, assign(socket, :selected_class, nil)}
  end

  def list_class_usage(socket, _params) do
    stats = TailwindClassUsage.summary_stats(
      socket.assigns.selected_timestamp,
      socket.assigns.selected_project
    )

    {stats, length(stats)}
  end

  defp page_title do
    app_name = Application.get_env(:css_linter, :app_name, "CSS")
    "#{app_name} Class Analysis"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-6">
        <h1 class="text-3xl font-bold">CSS Class Analysis</h1>
        <p class="text-base-content/70 mt-2">
          Analyze CSS class usage patterns across your codebase
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div class="card bg-base-200">
          <div class="card-body">
            <h3 class="text-sm font-medium text-base-content/60">Unique Classes</h3>
            <p class="text-3xl font-bold">{@analysis_summary.total_classes}</p>
          </div>
        </div>
        
        <div class="card bg-base-200">
          <div class="card-body">
            <h3 class="text-sm font-medium text-base-content/60">Total Files</h3>
            <p class="text-3xl font-bold">{@analysis_summary.total_files}</p>
          </div>
        </div>
        
        <div class="card bg-base-200">
          <div class="card-body">
            <h3 class="text-sm font-medium text-base-content/60">Total Usages</h3>
            <p class="text-3xl font-bold">{@analysis_summary.total_usages}</p>
          </div>
        </div>
      </div>

      <div class="flex gap-4 mb-6">
        <div class="form-control">
          <label class="label">
            <span class="label-text">Analysis Run</span>
          </label>
          <select class="select select-bordered" phx-change="select_timestamp">
            <option :for={ts <- @available_timestamps} value={ts} selected={ts == @selected_timestamp}>
              {Calendar.strftime(ts, "%Y-%m-%d %H:%M:%S")}
            </option>
          </select>
        </div>

        <div class="form-control">
          <label class="label">
            <span class="label-text">Project</span>
          </label>
          <select class="select select-bordered" phx-change="select_project">
            <option value="all" selected={@selected_project == "all"}>All Projects</option>
            <option :for={proj <- @available_projects} value={proj} selected={proj == @selected_project}>
              {proj}
            </option>
          </select>
        </div>
      </div>

      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <.live_table
            module={__MODULE__}
            socket={@socket}
            table_opts={[class: "table table-zebra table-pin-rows"]}
          >
            <:col :let={row} label="Class Name" sort_field={:class_name}>
              <button
                class="link link-primary"
                phx-click="select_class"
                phx-value-class={row.class_name}
              >
                {row.class_name}
              </button>
            </:col>
            <:col :let={row} label="Category">
              <span :for={cat <- List.wrap(row.category)} class="badge badge-sm mr-1">
                {cat}
              </span>
            </:col>
            <:col :let={row} label="Occurrences" sort_field={:total_occurrences}>
              {row.total_occurrences}
            </:col>
            <:col :let={row} label="Files" sort_field={:file_count}>
              {row.file_count}
            </:col>
          </.live_table>
        </div>
      </div>

      <%= if @selected_class do %>
        <div class="modal modal-open">
          <div class="modal-box max-w-4xl">
            <button class="btn btn-sm btn-circle absolute right-2 top-2" phx-click="close_details">
              ✕
            </button>
            
            <h3 class="font-bold text-lg mb-4">Class: {@selected_class}</h3>
            
            <div class="overflow-x-auto">
              <table class="table table-zebra table-sm">
                <thead>
                  <tr>
                    <th>File</th>
                    <th>Line</th>
                    <th>Context</th>
                  </tr>
                </thead>
                <tbody>
                  <%= for usage <- TailwindClassUsage.class_details(@selected_class, @selected_timestamp, @selected_project) do %>
                    <tr>
                      <td class="font-mono text-xs">{Path.relative_to_cwd(usage.file_path)}</td>
                      <td>{usage.line_number}</td>
                      <td class="font-mono text-xs max-w-md truncate">{usage.context}</td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl LiveTable.LiveResource
  def fields do
    [
      %{name: "Class Name", key: :class_name, sortable: true},
      %{name: "Category", key: :category, sortable: false},
      %{name: "Occurrences", key: :total_occurrences, sortable: true},
      %{name: "Files", key: :file_count, sortable: true}
    ]
  end
end
