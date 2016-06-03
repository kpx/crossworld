# Crossworld

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add crossworld to your list of dependencies in `mix.exs`:

        def deps do
          [{:crossworld, "~> 0.0.1"}]
        end

  2. Ensure crossworld is started before your application:

        def application do
          [applications: [:crossworld]]
        end

## Development

### Backend

* Install [elixir](http://elixir-lang.org/install.html)

Install deps and run:

	$ cd back && mix deps.get
	$ iex -S mix

### Frontend

Start a web server (for example using python):

	$ cd front && python3 -m http.server
