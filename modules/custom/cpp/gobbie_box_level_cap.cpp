/************************************************************************
 * Non-retail QoL: Gobbie Mystery Box level cap
 *
 * Reloads daily dial item pools after core init, omitting gear above
 * main.MAX_LEVEL from item_equipment. Enable in modules/init.txt:
 *   custom/cpp/gobbie_box_level_cap.cpp
 ************************************************************************/

#include "common/database.h"
#include "common/logging.h"
#include "common/settings.h"

#include "items/item.h"
#include "map/utils/moduleutils.h"

#include <vector>

namespace daily
{
extern std::vector<uint16> materialsDialItems;
extern std::vector<uint16> foodDialItems;
extern std::vector<uint16> medicineDialItems;
extern std::vector<uint16> sundries1DialItems;
extern std::vector<uint16> sundries2DialItems;
extern std::vector<uint16> specialDialItems;
} // namespace daily

namespace
{

void ClearDialPools()
{
    daily::materialsDialItems.clear();
    daily::foodDialItems.clear();
    daily::medicineDialItems.clear();
    daily::sundries1DialItems.clear();
    daily::sundries2DialItems.clear();
    daily::specialDialItems.clear();
}

void AppendDialItem(uint16 itemid, uint16 aH, ItemFlag flags)
{
    daily::specialDialItems.emplace_back(itemid);
    switch (aH)
    {
        case 38:
        case 39:
        case 40:
        case 41:
        case 42:
        case 43:
        case 44:
        case 50:
        {
            daily::materialsDialItems.emplace_back(itemid);
            break;
        }
        case 52:
        case 53:
        case 54:
        case 55:
        case 56:
        case 57:
        case 58:
        {
            daily::foodDialItems.emplace_back(itemid);
            break;
        }
        case 33:
        {
            daily::medicineDialItems.emplace_back(itemid);
            break;
        }
        case 15:
        case 36:
        case 49:
        {
            if ((flags & ItemFlag::CanUse) != ItemFlag::None)
            {
                daily::sundries1DialItems.emplace_back(itemid);
            }
            break;
        }
        case 47:
        case 51:
        {
            if (itemid == 489 || itemid == 17386)
            {
                break;
            }
            daily::sundries2DialItems.emplace_back(itemid);
            break;
        }
        default:
        {
            switch (itemid)
            {
                case 605:
                case 1020:
                case 1021:
                case 1022:
                case 1023:
                case 15453:
                case 15454:
                {
                    daily::sundries2DialItems.emplace_back(itemid);
                    break;
                }
                default:
                {
                    break;
                }
            }
        }
    }
}

void LoadLevelCappedDailyItems(uint8 maxLevel)
{
    ClearDialPools();

    const auto rset = db::preparedStmt(
        "SELECT b.itemid, b.aH, b.flags "
        "FROM item_basic b "
        "LEFT JOIN item_equipment e ON b.itemid = e.itemid "
        "WHERE b.flags & 4 > 0 "
        "AND (e.itemid IS NULL OR e.level <= ?)",
        maxLevel);

    if (!rset || !rset->rowsCount())
    {
        ShowError("[GobbieBoxLevelCap] Failed to load level-capped daily tally items (max level %u)", maxLevel);
        return;
    }

    while (rset->next())
    {
        const uint16 itemid = rset->get<uint16>("itemid");
        const uint16 aH     = rset->get<uint16>("aH");
        const auto   flags  = rset->get<ItemFlag>("flags");
        AppendDialItem(itemid, aH, flags);
    }

    ShowInfo(
        "[GobbieBoxLevelCap] Reloaded Gobbie dial pools for max item level %u (%zu special dial entries)",
        maxLevel,
        daily::specialDialItems.size());
}

} // namespace

class GobbieBoxLevelCapModule : public CPPModule
{
    void OnInit() override
    {
        const auto maxLevel = settings::get<uint8>("main.MAX_LEVEL");
        if (maxLevel == 0)
        {
            ShowWarning("[GobbieBoxLevelCap] main.MAX_LEVEL is 0; skipping dial pool reload");
            return;
        }

        LoadLevelCappedDailyItems(maxLevel);
    }
};

REGISTER_CPP_MODULE(GobbieBoxLevelCapModule);
