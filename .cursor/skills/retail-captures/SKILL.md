---
name: retail-captures
description: Interpret FFXI retail packet captures (eventview, npclogger, caplog, packetviewer) when implementing or verifying scripts. Use when the user provides captures, event dumps, or asks to match retail dialogue/events.
---

# Retail captures

Read `documentation/ai_agents/retail-packet-captures.md`.

Order: caplog (flow) → eventview/simple (event IDs) → npclogger (NPC pos) → packetviewer (only if needed).

Map:

- `CEventPacket` 0x032/0x034 `EventPara` → `quest:progressEvent(id)` / `quest:event(id)`
- `CMessageSpecialPacket` 0x02A → `quest:messageSpecial(id)`
- `CMessageNamePacket` 0x027 `MesNum` → dialogue IDs

Event dumps: `../FFXI-EventsDump/dumps/<Zone_Name>`. If that repo is missing, fetch zone dumps from [sruon/FFXI-EventsDump](https://github.com/sruon/FFXI-EventsDump).

Optional folders (`PathLog`, `ShopStock`, `KITrack`, `ActionView`) only when the task needs them. Do not invent event IDs.
