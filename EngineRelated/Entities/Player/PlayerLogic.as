#include "PlayerCommon.as";
#include "isLocalhost.as";
#include "ClientVars.as";
#include "TreeDeeSound.as";

const u16 replenish_time = 90;

void onInit(CBlob@ this)
{
	this.set_u8("prop_id", 1);
	
	this.Tag("player");
	this.set_f32("dir_x", 0.0f);
	this.set_f32("dir_y", 0.0f);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.addCommandID(camera_sync_cmd);
	this.addCommandID(shooting_cmd);
	this.addCommandID(sync_ammo);
	this.addCommandID(replenish_ammo);
	//this.addCommandID("cycle");
	
	this.set_f32("pitch", this.getTeamNum()==0?1.0:0.75f);
	this.set_s8("max_ammo", 8);
	this.set_s8("ammo", 8);
	this.set_u16("replenish_time", replenish_time);
	this.set_u32("ammo_bonus", 0);
	
	this.chatBubbleOffset = Vec2f(-20000, -50000);
	this.maxChatBubbleLines = -1;
	//this.server_SetHealth(0.5f);
	
	//this.SetLight(false);
    //this.SetLightRadius(80.0f);
    //this.SetLightColor(SColor(255, 200, 140, 170));
	//this.server_SetHealth(1.5f);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		if (XORRandom(100) < 33)
			server_CreateBlob("pick_hp", -1, this.getPosition());
	}
}

void onTick(CBlob@ this)
{
	if (!hasAmmoBonus(this)) this.set_s8("ammo", Maths::Min(this.get_s8("ammo"), this.get_s8("max_ammo")));
	if (isClient())
	{
		if (this.isMyPlayer())
		{
			if (!getHUD().hasMenus())
			{
				ManageCamera(this);
				ManageShooting(this);
			}
			
			//Ammo restoring
			s8 max = this.get_s8("max_ammo");
			s8 ammo = this.get_s8("ammo");

			u32 time = this.get_u32("lastshot");
			u32 diff = getGameTime()-time;

			u16 new_replenish_time = replenish_time;
			if (hasAmmoBonus(this))
			{
				new_replenish_time /= 2;
				max *= 2;
			}
			
			if (ammo < max)
			{
				if (ammo == 0)
				{
					if (diff >= new_replenish_time && !this.hasTag("requested_replenish"))
					{
						this.Tag("requested_replenish");
						CBitStream params;
						params.write_s8(max);
						this.SendCommand(this.getCommandID("replenish_ammo"), params);
					}
				}
				else if (ammo < max)
				{
					if (diff >= new_replenish_time/6)
					{
						this.Tag("requested_replenish");
						this.set_u32("lastshot", getGameTime());
						CBitStream params;
						params.write_s8(ammo+1);

						this.SendCommand(this.getCommandID("replenish_ammo"), params);
					}
				}
			}
		}
	}
}

void ManageShooting(CBlob@ this)
{
	if (this.get_bool("stuck")) return;

	const bool lmbClick	= this.isKeyJustPressed(key_action1);
	if (lmbClick && !(this.getSprite().isAnimation("shoot") && !this.getSprite().isAnimationEnded()))
	{
		s8 ammo = this.get_s8("ammo");
		if (ammo <= 0)
		{
			if (this.isMyPlayer())
				PlayTreeDeeSound("EmptyMagSound.ogg", this.getPosition(), 1.0f, this.get_f32("pitch")+0.2f + XORRandom(6)*0.01f);
			return;
		}
		if (!isLocalhost()) this.add_s8("ammo", -1);

		this.set_u32("lastshot", getGameTime());

		Shoot(this);
	}
}

void ManageCamera(CBlob@ this)
{
	CControls@ c = getControls();
	Driver@ d = getDriver();
	bool esc = c.isKeyJustPressed(KEY_ESCAPE);
	bool ctrl = c.isKeyJustPressed(KEY_RCONTROL);
	//if(ctrl){ this.set_bool("stuck", !this.get_bool("stuck")); this.Sync("stuck", true);}
	if(esc)
	{
		this.set_bool("stuck", !this.get_bool("stuck"));
	}

	if(ctrl)
	{
		this.set_bool("stuck", !this.get_bool("stuck"));
		if (!this.get_bool("stuck"))
		{
			Vec2f ScrMid = Vec2f(f32(d.getScreenWidth()) / 2, f32(d.getScreenHeight()) / 2);
			c.setMousePosition(ScrMid);
		}
	}

	f32 sensitivity = (getRules().exists("sensitivity") ? 21-getRules().get_f32("sensitivity")*20 : 10);

	if(!this.get_bool("stuck") && d !is null && c !is null)
	{
		Vec2f ScrMid = Vec2f(f32(d.getScreenWidth()) / 2, f32(d.getScreenHeight()) / 2);
		Vec2f dir = (c.getMouseScreenPos() - ScrMid)/sensitivity;
		f32 dirX = this.get_f32("dir_x");
		f32 dirY = this.get_f32("dir_y");
		dirX += dir.x;
		dirY = Maths::Clamp(dirY-dir.y,-90,90);
		this.set_f32("dir_x", dirX);
		this.set_f32("dir_y", dirY);

		if (getDriver().getScreenPosFromWorldPos(this.getAimPos()).x != ScrMid.x || getDriver().getScreenPosFromWorldPos(this.getAimPos()).y != ScrMid.y)
			c.setMousePosition(ScrMid);
	}
	if(getGameTime() % 3 == 0)
	{
		SyncCamera(this);
	}
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID(camera_sync_cmd))
	{
		HandleCamera(this, params, !canSend(this));
	}
	
	if (getNet().isServer())
	{
		if (cmd == this.getCommandID(shooting_cmd))
		{
			CreateBullet(this, params);
			this.add_s8("ammo", -1);

			CBitStream params1;
			params1.write_s8(this.get_s8("ammo"));
			this.SendCommand(this.getCommandID(sync_ammo), params1);
		}
		else if (cmd == this.getCommandID(replenish_ammo))
		{
			s8 requested;
			if (!params.saferead_s8(requested)) return;

			s8 max = this.get_s8("max_ammo");
			if (hasAmmoBonus(this))
			{
				max *= 2;
			}

			if (requested > 0)
				max = Maths::Min(max, requested);

			this.set_s8("ammo", max);

			CBitStream params1;
			params1.write_s8(this.get_s8("ammo"));
			this.SendCommand(this.getCommandID(sync_ammo), params1);
		}
	}
	
	if (getNet().isClient() && cmd == this.getCommandID(sync_ammo))
	{
		s8 ammo;
		if (!params.saferead_s8(ammo)) return;

		this.set_s8("ammo", ammo);
		if (this.isMyPlayer() && this.hasTag("requested_replenish")) 
		{
			s8 max = this.get_s8("max_ammo");
			s8 cur = this.get_s8("ammo");

			if (hasAmmoBonus(this))
			{
				max *= 2;
			}

			string sound = cur < max ? "LaserChargeShort.ogg" : "LaserCharge.ogg"; 
			PlayTreeDeeSound(sound, this.getPosition(), 1.0f, 1.0f);
	
			this.Untag("requested_replenish");
		}
	}
}

bool hasAmmoBonus(CBlob@ this)
{
	u32 bonus_time = this.get_u32("ammo_bonus");
	return bonus_time > getGameTime();
}