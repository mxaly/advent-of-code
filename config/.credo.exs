%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Readability.LargeNumbers, [only_greater_than: 999_999]},
        {Elixir.Credo.Check.Refactor.Nesting, [max_nesting: 3]}
      ]
    }
  ]
}
