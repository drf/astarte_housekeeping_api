defmodule Astarte.Housekeeping.APIWeb.ErrorView do
  use Astarte.Housekeeping.APIWeb, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("realm_not_found.json", _assigns) do
    %{errors: %{detail: "realm not found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end