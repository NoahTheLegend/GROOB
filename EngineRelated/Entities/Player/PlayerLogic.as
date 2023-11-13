#include "PlayerCommon.as";
#include "isLocalhost.as";
#include "ClientVars.as";
#include "ClientConfig.as";
#include "TreeDeeSound.as"

void onInit(CBlob@ this)
{
	this.set_u8("prop_id", 1);
	
	this.Tag("player");
	this.set_f32("dir_x", 0.0f);
	this.set_f32("dir_y", 0.0f);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.set_f32("pitch", this.getTeamNum()==0?1.0:0.75f);

	this.addCommandID(camera_sync_cmd);
	this.addCommandID(shooting_cmd);
	this.addCommandID(sync_ammo);
	this.addCommandID(replenish_ammo);
	this.addCommandID("cycle");

	this.set_s8("max_ammo", 8);
	this.set_s8("ammo", 8);
	
	this.chatBubbleOffset = Vec2f(-20000, -50000);
	this.maxChatBubbleLines = -1;
	
	this.SetLight(false);
    //this.SetLightRadius(80.0f);
    //this.SetLightColor(SColor(255, 200, 140, 170));
	//this.server_SetHealth(1.5f);
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if (isClient())
	{
		if (this.isMyPlayer())
		{
			if (!getHUD().hasMenus())
			{
				ManageCamera(this);
				ManageShooting(this);
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
	if(!this.get_bool("stuck") && d !is null && c !is null)
	{
		Vec2f ScrMid = Vec2f(f32(d.getScreenWidth()) / 2, f32(d.getScreenHeight()) / 2);
		Vec2f dir = (c.getMouseScreenPos() - ScrMid)/10;
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
			this.set_s8("ammo",this.get_s8("max_ammo"));

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
		if (this.hasTag("requested_replenish")) 
		{
			PlayTreeDeeSound("LaserCharge.ogg", this.getPosition(), 1.0f, this.get_f32("pitch")+0.25f);
	
			this.Untag("requested_replenish");
		}
	}
}