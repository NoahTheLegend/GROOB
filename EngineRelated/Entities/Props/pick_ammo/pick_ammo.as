#include "TreeDeeSound.as"

const u32 bonus_time = 30*30; // 30 seconds
void onInit(CBlob@ this)
{
	
	this.set_u8("prop_id", 6);
	this.set_u8("prop_bonus_id", 1);
	this.set_string("prop_tilesheet", "pick_ammo.png");
	this.Tag("invincible");
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);
	shape.SetRotationsAllowed(false);

	ShapeConsts@ consts = shape.getConsts();
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	
	if(isClient())
		PlayTreeDeeSound("Bonus.ogg", this.getPosition(), 2.0f, 1.0f);

	this.addCommandID("sync_bonus");
	this.getShape().SetStatic(true);
	this.server_SetTimeToDie(30.0f+XORRandom(151)*0.1f);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null && blob.getName() == "player")
	{
		if (isServer())
		{
			u32 endtime = getGameTime()+bonus_time;
			this.set_u32("ammo_bonus", endtime);

			CBitStream params;
			params.write_u16(blob.getNetworkID());
			params.write_u32(endtime);
			this.SendCommand(this.getCommandID("sync_bonus"), params);

			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	if (!isClient()) return;

	f32 mod = this.getTimeToDie() < 0.5f ? 1.0f : 0.0f;
	PlayTreeDeeSound("PickupBonus.ogg", this.getPosition(), 1.5f - mod, 1.0f+XORRandom(11)*0.01f+mod/3);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync_bonus"))
	{
		u16 id;
		u32 endtime;
		if (!params.saferead_u16(id)) return;
		if (!params.saferead_u32(endtime)) return;

		CBlob@ player = getBlobByNetworkID(id);
		if (player is null) return;

		player.set_u32("ammo_bonus", endtime);
	}
}