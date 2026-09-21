# MM2

Murder Mystery 2 script built on [Iris-X](https://github.com/Kleitnick/Iris-X).

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kleitnick/Iris-X-Murder-Mystery-2/refs/heads/main/MM2_Script.lua"))()
```

## Features

**ESP**
- Box, Name, Role, Distance
- Role color coding: Murderer, Sheriff, Innocent
- Configurable max distance

**Fly**
- WASD movement, Space up, LeftCtrl down
- Adjustable speed

**Misc**
- WalkSpeed, JumpPower
- Noclip
- Infinite Jump

## UI

- Light theme by default
- Collapsible sections
- Unload button
- Draggable, resizable window

## Notes

- Requires an executor with `Drawing` API support
- Role detection reads the local Backpack for `Knife` (Murderer) or `Gun` (Sheriff)
- `Fly` uses `BodyVelocity` and `BodyGyro` on the local `HumanoidRootPart`
- `Noclip` disables `CanCollide` on all local character parts
