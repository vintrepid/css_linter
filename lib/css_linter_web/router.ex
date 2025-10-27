defmodule CssLinterWeb.Router do
  @moduledoc """
  Router helpers for mounting CSS Linter LiveViews in your Phoenix app.
  
  ## Usage
  
  Simply add the LiveView directly to your router:
  
      scope "/admin" do
        pipe_through [:browser, :require_authenticated_user]
        live "/css-analysis", CssLinterWeb.Live.AnalysisLive, :index
      end
  """
end
