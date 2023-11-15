#define SERVER_ONLY
#include "TreeDeeMap.as"

const u16 frequency_min = 150;
const u16 frequency = 900;
const u16 frequency_rand = 150;
const u16 player_mod = 30; // decrease per player

const string[] names = {
    "pick_ammo",
    "pick_hp"
};

const u8[] rarity = { // 1 (rarest) to 100 (most common)
    25,
    50
};

const u8[] frequency_factor = { // increase frequency till next roll
    1,
    2
};

u32 getNextTime()
{
    u16 plyc = getPlayersCount();
    return Maths::Max(frequency_min, int(frequency)+XORRandom(frequency_rand)-plyc*player_mod);
}

void onInit(CRules@ this)
{
    this.set_u32("next_loot", getGameTime() + getNextTime()/5);
}

void onRestart(CRules@ this)
{
    this.set_u32("next_loot", getGameTime() + getNextTime()/5);
}

void onTick(CRules@ this)
{
    if (getGameTime()>this.get_u32("next_loot"))
    {
        Vec2f pos = getSpawnPos();
        if (pos == Vec2f_zero)
        {
            //error("Could not spawn loot");
            return;
        }

        f32 mod = 1;
        CBlob@ loot = doSpawnLoot(this, pos, getLootName(mod));
        if (loot !is null)
        {
            this.set_u32("next_loot", getGameTime() + getNextTime() / mod);
        }
    }
}

Vec2f getSpawnPos()
{
    CMap@ map = getMap();
    if (map is null) return Vec2f_zero;
    
    u32 mw = map.tilemapwidth;
    u32 mh = map.tilemapheight;

    for (u8 i = 0; i < 50; i++)
    {
        u32 rw = XORRandom(mw);
        u32 rh = XORRandom(mh);
        if (map.getTile(Vec2f(rw*8, rh*8)).type != 32) continue;
        return Vec2f(rw*16+8, rh*16+8);
    }

    return Vec2f_zero;
}

/*Vec2f getSpawnPos()
{
    ThreeDeeMap@ three_dee_map = getThreeDeeMap();
	if (three_dee_map is null) return Vec2f_zero;
    CMap@ map = getMap();
    if (map is null) return Vec2f_zero;
    
    u32 mw = map.tilemapwidth;
    u32 mh = map.tilemapheight;

    for (u8 i = 0; i < 50; i++)
    {
        u32 rw = XORRandom(mw);
        u32 rh = XORRandom(mh);
        SColor col = three_dee_map.heightMapImage.get(rw, rh);
        if (col.getRed() < 10) continue;
        return Vec2f(rw*16+8, rh*16+8);
    }

    return Vec2f_zero;
}*/

CBlob@ doSpawnLoot(CRules@ this, Vec2f pos, string name)
{
    CBlob@ blob = server_CreateBlob(name, -1, pos);
    return blob;
}

string getLootName(f32&out mod)
{
    for (u8 j = 0; j < 50; j++)
    {
        for (u8 i = 0; i < 2; i++)
        {
            if (XORRandom(100) < rarity[i])
            {
                mod = frequency_factor[i];
                return names[i];
            }
        }
    }
    return getLootName(mod);
}