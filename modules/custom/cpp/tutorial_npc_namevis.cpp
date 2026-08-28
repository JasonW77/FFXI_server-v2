/************************************************************************
 * Non-retail QoL: Per-player tutorial NPC quest-marker visibility.
 *
 * namevis is global per NPC; this helper sends a one-off entity update so
 * only the target player sees a different icon state. Enable in init.txt:
 *   custom/cpp/tutorial_npc_namevis.cpp
 ************************************************************************/

#include "map/entities/baseentity.h"
#include "map/entities/charentity.h"
#include "map/lua/lua_baseentity.h"
#include "map/packets/basic.h"
#include "map/utils/moduleutils.h"
#include "map/utils/zoneutils.h"

namespace
{

void SendNpcNamevisToPlayer(CLuaBaseEntity* PLuaPlayer, uint32 npcId, uint8 namevis)
{
    if (!PLuaPlayer)
    {
        return;
    }

    auto* PChar = dynamic_cast<CCharEntity*>(PLuaPlayer->GetBaseEntity());
    if (!PChar)
    {
        return;
    }

    auto* PEntity = zoneutils::GetEntity(npcId, TYPE_NPC);
    if (!PEntity)
    {
        return;
    }

    const uint8 saved = PEntity->namevis;
    PEntity->namevis  = namevis;
    PChar->updateEntityPacket(PEntity, ENTITY_UPDATE, UPDATE_HP);
    PEntity->namevis = saved;
}

} // namespace

class TutorialNpcNamevisModule : public CPPModule
{
    void OnInit() override
    {
        TracyZoneScoped;

        sol::table xiTable = lua["xi"];
        if (!xiTable.valid())
        {
            xiTable     = lua.create_table();
            lua["xi"]   = xiTable;
        }

        sol::table custom = xiTable["custom"];
        if (!custom.valid())
        {
            custom           = lua.create_table();
            xiTable["custom"] = custom;
        }

        custom.set_function("sendNpcNamevisToPlayer", &SendNpcNamevisToPlayer);
    }
};

REGISTER_CPP_MODULE(TutorialNpcNamevisModule);
