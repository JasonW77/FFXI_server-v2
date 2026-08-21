---
name: retail-captures
description: Interpret FFXI retail packet captures (eventview, npclogger, caplog, packetviewer) when implementing or verifying scripts. Use when the user provides captures, event dumps, or asks to match retail dialogue/events.
---

# Retail captures

Read `documentation/ai_agents/retail-packet-captures.md`.

Order: caplog (flow) → eventview/simple (event IDs) → npclogger (NPC pos) → packetviewer (only if needed). ActionView simple can confirm item Anim/Msg when present.

Map:

- `CEventPacket` 0x032/0x034 `EventPara` → `quest:progressEvent(id)` / `quest:event(id)`
- `CMessageSpecialPacket` 0x02A → `quest:messageSpecial(id)`
- `CMessageNamePacket` 0x027 `MesNum` → dialogue IDs
- Item use success: `0x028` **ItemFinish** → `item_usable.animation` (12-bit result animation), param, and `messageID` (wire `MsgBasic` / `xi.msg.basic.*` when missing). Caplog text confirms the printed line.
- Item use fail: `0x029`/`0x02A` + caplog → unable-to-use `xi.msg.basic.*`.
- Item use silent fail: capturer notes “no error message,” client may send ItemStart with FourCC **ItemInterrupt** (`spit`) and **no** fail `0x029` → `onItemCheck` returns **-1** (`RefuseSilently` in `item_state.cpp`). Do not invent a message ID.

Wiki (BG-Wiki activate time, “cannot use at cap”) is not a packet. Do not copy a nearby potion (`30`) or food (`28`) animation. Leave `0` and TODO until captured.

OneDrive/Drive links may 403 from the agent. Ask the user to drop the zip locally, then unpack under a scratch folder (do not commit capture files).

Event dumps: `../FFXI-EventsDump/dumps/<Zone_Name>`. If that repo is missing, fetch zone dumps from [sruon/FFXI-EventsDump](https://github.com/sruon/FFXI-EventsDump).

Optional folders (`PathLog`, `ShopStock`, `KITrack`, `ActionView`) only when the task needs them. Do not invent event IDs, message IDs, or animation IDs.
