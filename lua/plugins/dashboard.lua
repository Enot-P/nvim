vim.pack.add({ "https://github.com/goolord/alpha-nvim" })

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⣶⣶⣶⣶⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣮⣻⡿⣿⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣯⣿⠋⣿⣽⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣾⡟⠁⢹⣷⢿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠋⠀⠀⣿⣷⣷⣆⠀⠀⢀⣀⣀⣠⣤⣄⣀⡀⠀⣀⣀⣀⡀⠀⠀⣀⣀⣀⣀⣀⣀⣀⣀⣤⣄⣤⣤⡄⠀⠀⣄⣀⣀⡄⣠⣤⣤⣤⣤⣤⣤⣄⢠⣤⣤⡄⠀⢀⣀⣠⣤⣤⣤⣤⣤⣀⡰⣤⣤⣤⣤⣤⣤⡖⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣶⣾⣿⣿⣿⣶⣶⣶⣿⡿⣿⣿⣄⠀⠀⠙⣿⣿⠉⠻⠯⣟⢦⡈⣿⣿⠁⠀⠀⣽⣿⢿⣿⣿⡟⠛⠛⢿⠀⠻⣿⣿⣧⡀⠀⠙⣿⣿⠏⠛⠛⣿⢿⠛⠛⠿⠆⣿⣿⠀⠀⢸⣿⡟⢹⣿⡟⠉⢱⣿⠇⢻⣿⡏⠀⠙⢿⡇⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠋⠉⣿⣯⣿⠏⠉⠉⠁⠉⢻⣿⣿⣷⡀⠀⠀⣿⣿⠀⠀⠈⢹⣻⣷⠘⣿⣧⠀⣼⣿⠏⢸⣿⣿⣧⣤⣤⡌⠀⠈⣿⣿⣿⣿⣧⡀⣿⣇⠀⠀⠀⣿⣿⠀⠀⠀⠀⣿⣿⠀⠀⢸⣿⡇⢸⣿⡇⢶⣿⠁⠀⢸⣿⣷⣴⣶⠄⠁⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣻⡿⠀⠀⠀⠀⠀⠈⣿⣿⣿⣧⡀⠀⣿⣿⠀⠀⠀⣸⣿⡿⠀⢹⣿⣾⣿⠃⠀⢸⣿⣿⡇⠀⠉⠀⠀⠀⣷⡗⠙⠻⣿⣿⣿⣿⠀⠀⠀⣿⢻⠀⠀⠀⠀⣿⣿⡀⠀⢹⣿⡇⢸⣿⠇⠈⢿⣯⡀⢸⣿⡇⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣷⣤⣿⣿⣧⣤⣴⣿⠟⠁⠀⠀⢿⡿⠁⠀⢀⣸⣿⣿⣧⣤⣤⣶⠇⣠⣿⠇⠀⠀⠈⠻⣿⠟⠀⠀⢠⣿⣿⡀⠀⠀⠀⠙⢿⣷⣶⢿⣿⢇⣺⣿⣇⠀⠈⢿⣷⣿⣿⣷⡤⢤⣴⠏⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⠟⠛⠛⠛⠛⠀⠀⢀⣠⣴⠂⠀⠀⠈⠉⠉⣉⣉⣉⣉⣉⣉⣀⣀⣀⣀⣀⣀⣉⣁⣀⣀⣀⠀⢀⣀⣀⣀⣀⣀⠀⣉⣀⣀⣀⣀⣀⠀⠁⠀⠀⠀⠋⠀⠀⠀⢀⣄⣀⣀⣠⣅⣀⠀⣀⣀⣉⣉⣉⡀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣷⣾⣿⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⢿⣿⣿⣿⡟⠀⠈⢿⣿⡿⢿⣿⣧⠀⠀⠀⠀⠀⠀⠀⢤⣿⣿⡿⣿⣿⡿⠋⠀⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡿⠛⠁⠀⠀⠰⣿⣿⠟⠛⠛⠚⠛⠛⣿⣿⣿⣿⠛⠛⠛⠻⠻⢿⣿⠀⢸⣿⣿⣿⡇⠀⠀⠈⣿⣿⣽⣿⣿⣧⠀⠀⠀⠀⠀⣰⣿⣿⣽⣿⣿⡏⠀⠀⠀⠀⢸⣿⣿⣿⣿⠉⠉⠉⠉⠉⠙⠻⢣⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⣠⣴⣶⣶⣄⠀⠀⠀⢀⣀⢀⣄⡀⣀⣴⣤⣿⣿⣿⣷⣶⣶⣶⣤⣤⣿⣴⣶⣶⣦⣤⣤⣤⣿⣿⣿⣧⣤⣤⣤⣤⣤⣤⣝⣤⣼⣿⣿⣿⣧⣤⣤⣴⣿⣿⣿⣿⣿⣿⣷⣠⣤⣤⣼⣿⣿⡿⢻⣿⣿⡇⣤⣤⣤⣤⣼⣟⣛⣛⣛⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀",
    "⠸⣿⣿⣿⣿⣿⣷⣿⣻⣿⢯⣿⣿⣽⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣞⣿⣿⣿⣯⢿⣻⣿⣿⡿⣽⢾⣿⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡄",
    "⠈⠻⣿⣿⣿⡿⠿⠿⠿⢿⠾⠿⢷⣿⣏⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⡇⡿⡿⠿⠿⠿⠿⠿⠿⠿⠿⢿⣿⡿⠿⠿⠿⠿⠿⣿⣿⣧⠿⠎⢿⣿⣿⣷⣿⢿⡿⠹⠿⢸⣿⣿⣿⠿⠿⠿⠿⢿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠟⠋⠁⠀",
    "⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⣿⣿⣿⣍⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡆⠀⠀⢰⣿⣿⣿⠀⠀⠈⢯⣳⣿⣯⣿⠃⠀⠀⢸⣿⢯⣽⠀⠀⠀⠀⢸⣿⣷⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣷⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡧⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣇⠀⢀⣾⣿⣿⣿⠀⠀⠀⠈⢻⣿⣾⠃⠀⠀⠀⣸⣿⣯⢿⡆⠀⠀⢀⣾⣿⣿⣿⣿⣶⣶⣶⣶⣶⣾⣶⣿⡟⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠿⣿⣟⠻⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⢿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⣾⠿⠟⠛⠛⠿⠀⠾⠽⠿⠿⠛⠂⠀⠀⠀⠀⠻⠋⠀⠀⠀⠀⠛⠛⠛⠛⠛⠂⠐⠿⠷⠯⠿⠷⢿⣿⣿⣿⣿⣿⡿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡾⠟⠋⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠳⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀",
}

dashboard.section.buttons.val = {
    dashboard.button("f", "" .. " Find File", function() Snacks.picker.files() end),
    dashboard.button("n", "" .. " New File", "enew"),
    dashboard.button("s", "" .. " Find session", function() require("resession").load() end),
    dashboard.button("p", "󰣷" .. " Find project", function() Snacks.picker.projects() end),
    dashboard.button("c", "" .. " Config", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end),
    dashboard.button("q", "󰠚" .. " Quit", "<Cmd>qa<CR>"),
}

-- Секция сессий
local function get_session_buttons()
    local ok, resession = pcall(require, "resession")
    if not ok then
        return {}
    end
    local sessions = resession.list()
    if not sessions or #sessions == 0 then
        return { { type = "text", val = "No sessions found 😥", opts = { position = "center" } } }
    end
    local btns = {}
    for i, name in ipairs(sessions) do
        local key = tostring(i - 1)
        table.insert(btns, dashboard.button(key, "󱇒 " .. name, function() resession.load(name) end))
    end
    return btns
end

local sessions_section = {
    type = "group",
    val = function()
        return {
            { type = "text", val = "Sessions", opts = { hl = "Special", position = "center" } },
            { type = "padding", val = 1 },
            { type = "group", val = get_session_buttons() },
        }
    end,
}

alpha.setup({
    layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        sessions_section,
        { type = "padding", val = 2 },
        dashboard.section.footer,
    },
    opts = {},
})
