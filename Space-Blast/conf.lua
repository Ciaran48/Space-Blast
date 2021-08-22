-- The conf will set the title of the window,the version, --
-- set the aspect ratio, set the window icon and attatch --
--the console--

function love.conf(t)
    t.title = "Space Blast"
    t.version = "11.3"
    t.console = true
    t.window.width = 1280
    t.window.height = 720
    t.window.icon = 'sprites/icon.png'
end
