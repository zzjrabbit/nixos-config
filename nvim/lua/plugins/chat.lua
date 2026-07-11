return {
  'wsdjeg/chat.nvim',
  version = false,
  config = function ()
    require("chat").setup({
      provider = "deepseek",
      model = "deepseek-v4-flash",
      api_key = {
        deepseek = os.getenv("DPSK_API_KEY"),
      },
    })
  end,
  dependencies = {
    'wsdjeg/job.nvim', -- Required
    'wsdjeg/picker.nvim', -- Optional but recommended
  },
}

