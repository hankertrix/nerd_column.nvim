# The VHS tape for the demo video

# Output to a video
Output demo.mp4

# Require Neovim
Require nvim

# Settings for the demo
Set FontSize 20
Set FontFamily "CaskaydiaCove NFM"
Set Theme "BlulocoDark"
Set Padding 20
Set Margin 0

# Hide the setup part
Hide

# Open Neovim
Type "nvim demo.md" Enter

# Set the typing speed to an extremely fast typing speed
Set TypingSpeed 0.1ms

# Change the colour scheme to Bluloco dark
Type ":colorscheme bluloco-dark" Enter

# Disable blink.cmp
Type `:lua require("blink.cmp.config")`
Type ".merge_with({ enabled = function() return false end })" Enter
Type ":" Escape
Sleep 2s

# Set the typing speed to a normal typing speed
Set TypingSpeed 150ms

# Show the demonstration
Show
Type "i"
Sleep 250ms
Type "Hi there!" Enter 2
Sleep 1s
Type "Welcome to the demonstration for Nerd Column!"
Sleep 1s
Enter 2
Type "Nerd Column is a plugin that automatically enables your "
Type "colour column when it is needed, which is when you exceed "
Type "the length set on the colour column, like right now!"
Sleep 1s
Enter 2
Type "The colour column is currently set to `80`, which you can "
Type "see by using the `:set colorcolumn?` command."
Escape
Sleep 1s
Type ":set colorcolumn?" Enter
Sleep 1s
Type "A" Enter 2
Type "Now let's delete some text and watch the colour column disappear!"
Escape
Type "2k"
Type "dap"
Sleep 1s
Type "2k"
Type "dap"
Sleep 500ms
Type "u"
Type "u"
Sleep 1s
Ctrl+R
Ctrl+R
Sleep 1s
Type "u"
Type "u"
Sleep 1s
Ctrl+R
Ctrl+R
Sleep 1s
Type "G"
Type "A" Enter 2
Type "The colour column disappeared, as none of the lines exceeded "
Type "the line length of 80, except for this one that is being typed."
Sleep 1s
Enter 2
Type "Nerd Column also provides a few commands that you can use to enable "
Type "or disable the plugin." Enter 2
Type "The `:NerdColumnEnable` command will enable the plugin regardless "
Type "of its previous state, and the `:NerdColumnDisable` command will disable "
Type "the plugin regardless of its previous state. "
Type "The `:NerdColumnToggle` command will toggle the plugin on and off, "
Type "based on whether the plugin was enabled or disabled."
Sleep 1s
Enter 2
Type "Let's try the commands out!"
Sleep 500ms
Escape
Type ":NerdColumnDisable" Enter
Sleep 1s
Type ":NerdColumnEnable" Enter
Sleep 1s
Type ":NerdColumnToggle" Enter
Sleep 1s
Type ":NerdColumnToggle" Enter
Sleep 1s
Type ":NerdColumnToggle" Enter
Sleep 1s
Type ":NerdColumnToggle" Enter
Sleep 1s
Type "A" Enter 2
Type "Okay, that is all for this demonstration, goodbye!"
Escape
Type ":q!"
Sleep 1s
Enter
