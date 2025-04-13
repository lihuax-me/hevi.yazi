# hevi preview plugin for yazi

git clone this repo to `~/.config/yazi/plugins/`

```bash
git clone https://github.com/zehua0417/hevi.yazi.git ~/.config/yazi/plugins/hevi.yazi
```

add following code to `~/.config/yazi/yazi.toml`

```lua
[plugin]

prepend_previewers = [
    { name = "*.{bin,exe}", run = "hevi" },
]
```

then you can preview `*.exe` of `*.bin` files using hevi in yazi

Not bad, right? How about giving a star? 🌟😄
