#include "TreeDeeSound.as"

void onInit(CBlob@ this)
{
	this.set_u8("prop_id", 2);
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);
	shape.SetRotationsAllowed(false);

	ShapeConsts@ consts = shape.getConsts();
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	
	if(isClient())
		PlayTreeDeeSound("Shoot.ogg", this.getPosition(), 2.0f, (this.getTeamNum()==0?1.33f:0.9f) + XORRandom(16)*0.01f);
	
	//this.SetLight(true);
    //this.SetLightRadius(40.0f);
    //this.SetLightColor(this.getTeamNum() == 0 ? SColor(255, 0, 0, 100) : SColor(255, 100, 0, 0));

	this.server_SetTimeToDie(3.0f);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob)
{
	if(blob.getTeamNum() == this.getTeamNum() || blob.getName() == "bullet" || blob.hasTag("invincible"))
	{
		return false;
	}
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	//if(blob is null)	//map collision
	//	this.server_Die();
	if(this.hasTag("dead")) return;
	
	if(blob !is null)
	{
		if(blob.getTeamNum() == this.getTeamNum() || blob.hasTag("invincible"))
			return;

		if (isServer()) this.server_Hit(blob, Vec2f_zero, Vec2f_zero, 0.5f, 1);

		if(isClient() && blob.getPlayer() !is null)
			PlayTreeDeeSound("GrobberHit.ogg", this.getPosition(), 1.3, 0.9+ XORRandom(26)*0.01f);
	}
	this.setVelocity(Vec2f_zero);
	this.server_SetTimeToDie(0.6f);
	this.getShape().SetStatic(true);
	//this.server_Die();
}

void onTick(CSprite@ sprite)
{
	CBlob@ this = sprite.getBlob();
	if (this is null) return;
	//print("getTimeToDie(): "+this.getTimeToDie());

	if(isClient())
	{
		if(!this.hasTag("dead"))
		{
			if (this.getVelocity().getLength() <= 0.2f || this.getTimeToDie() <= 0.6f)
			{
				this.setVelocity(Vec2f_zero);
				sprite.SetAnimation("death");

				if(sprite.animation.frame == 4)
				{
					this.Tag("dead");
					this.server_Die();
				}
			}
		}
	}
}