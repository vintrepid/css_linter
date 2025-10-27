defmodule CssLinterWeb.Router do
  @moduledoc """
  Router helpers for mounting CSS Linter LiveViews in your Phoenix app.
  
  ## Usage
  
  In your router:
  
      import CssLinterWeb.Router
      
      scope "/admin" do
        pipe_through [:browser, :require_authenticated_user]
        css_linter_routes("/css-analysis")
      end
  """

  defmacro css_linter_routes(path \\ "/css-analysis") do
    quote bind_quoted: [path: path] do
      import Phoenix.LiveView.Router
      
      live path, CssLinterWeb.Live.AnalysisLive, :index
    end
  end
end
