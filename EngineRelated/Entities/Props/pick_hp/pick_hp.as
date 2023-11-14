#include "TreeDeeSound.as"

void onInit(CBlob@ this)
{
	this.set_u8("prop_id", 6);
	this.set_u8("prop_bonus_id", 0);
	this.set_string("prop_tilesheet", "pick_hp.png");
	this.Tag("invincible");
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);
	shape.SetRotationsAllowed(false);

	ShapeConsts@ consts = shape.getConsts();
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	
	if(isClient())
		PlayTreeDeeSound("Bonus.ogg", this.getPosition(), 2.0f, 1.0f);
	
	this.getShape().SetStatic(true);
	this.server_SetTimeToDie(30.0f+XORRandom(151)*0.1f);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null && blob.getName() == "player" && blob.getHealth() < blob.getInitialHealth())
	{
		if (isServer())
		{
			blob.server_SetHealth(blob.getInitialHealth());
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