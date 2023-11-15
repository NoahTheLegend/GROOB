#include "TreeDeeMap.as";
#include "ClientVars.as";

#define CLIENT_ONLY

float ratio = f32(getDriver().getScreenWidth()) / f32(getDriver().getScreenHeight());
pistol gun = pistol(); 

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_posthud, "RenderHUDstuff.as", "hud", 2.0f);
	if(gun !is null)
		gun = pistol();
}

class pistol
{
	Vertex[] v_const;
	Vertex[] v_raw;
	u16[] v_i;
	
	pistol(){}
	
	pistol()
	{
		Vec2f ScS = Vec2f(getDriver().getScreenWidth()+6, getDriver().getScreenHeight());
		Vertex[] _v_const = 
		{
			Vertex(ScS.x/2-(ScS.y-ScS.y/2)/2+(ScS.y-ScS.y/2)/128, ScS.y/2, 0, 0, 0, color_white),
			Vertex(ScS.x/2+(ScS.y-ScS.y/2)/2+(ScS.y-ScS.y/2)/128, ScS.y/2, 0, 1.000f/3, 0, color_white),
			Vertex(ScS.x/2+(ScS.y-ScS.y/2)/2+(ScS.y-ScS.y/2)/128, ScS.y,   0, 1.000f/3, 1, color_white),
			Vertex(ScS.x/2-(ScS.y-ScS.y/2)/2+(ScS.y-ScS.y/2)/128, ScS.y,   0, 0, 1, color_white)
		};
		u16[] _v_i = {
			0,1,2,
			0,2,3
		};
		
		this.v_const = _v_const;
		this.v_raw = this.v_const;
		this.v_i = _v_i;
	}
	
	void DrawPistol(CBlob@ blob, int team)
    {
		if (blob is null) return;

		f32 dir_y = blob.get_f32("dir_y");

		for (u8 i = 0; i < 4; i++)
		{
			this.v_raw[i].y = this.v_const[i].y + Maths::Max(0,dir_y-8) * 8;
		}

        Render::RawTrianglesIndexed("Pistol"+team+".png", this.v_raw, this.v_i);
    }
	
	void SetFrame(int _index)
	{
		v_raw[0].u = v_raw[3].u = 1.000f/3*_index;
		v_raw[1].u = v_raw[2].u = 1.000f/3*_index+1.000f/3;
	}
	
	void SetColor(SColor color)
	{
		v_raw[0].col = v_raw[3].col = v_raw[1].col = v_raw[2].col = color;
	}
};

void hud(int id)
{
	CPlayer@ p = getLocalPlayer();
	if(p !is null)
	{
		CBlob@ b = p.getBlob();
		if(b !is null)
		{
			Render::SetTransformScreenspace();
			
			Vec2f intPos = b.getInterpolatedPosition()/8;
			ThreeDeeMap@ three_dee_map = getThreeDeeMap();
			gun.SetColor(three_dee_map.lightMapImage.get(intPos.x, intPos.y));
			gun.DrawPistol(b, b.getTeamNum());
			
			Render::SetAlphaBlend(true);
			Vec2f ScS = Vec2f(getDriver().getScreenWidth(), getDriver().getScreenHeight());
			
			CRules@ rules = getRules();
			SColor color_crosshair = SColor(255, rules.get_u8("c_red"), rules.get_u8("c_green"), rules.get_u8("c_blue"));
			//crosshair
			f32 amt = 16*(1+max_crosshair_scale*rules.get_f32("crosshair_scale"));
			//printf(""+color_crosshair.getRed()+" "+color_crosshair.getGreen()+" "+color_crosshair.getBlue());
			Vertex[] crosshairV = 
			{
				Vertex(ScS.x/2-amt, ScS.y/2-amt, 0,	0, 0, color_crosshair),
				Vertex(ScS.x/2+amt, ScS.y/2-amt, 0,	1, 0, color_crosshair),
				Vertex(ScS.x/2+amt, ScS.y/2+amt, 0,	1, 1, color_crosshair),
				Vertex(ScS.x/2-amt, ScS.y/2+amt, 0,	0, 1, color_crosshair)
			};
			u16[] crosshairID = {
				0,1,2,
				0,2,3
			};
			Render::RawTrianglesIndexed("Crosshair"+rules.get_u8("crosshair")+".png", crosshairV, crosshairID);

			u8 segw = 30;
			u8 segh = 16;
			//HP bar
			f32 health = b.getInitialHealth()*4;
			for (u8 i = 0; i < health; i++)
			{
				Vertex[] segV = 
				{
					Vertex(40-segw, ScS.y-16-(segh+2)*i-segh, 0,	0, 0, color_white),
					Vertex(40+segw, ScS.y-16-(segh+2)*i-segh, 0,	1, 0, color_white),
					Vertex(40+segw, ScS.y-16-(segh+2)*i+segh, 0,	1, 1, color_white),
					Vertex(40-segw, ScS.y-16-(segh+2)*i+segh, 0,	0, 1, color_white)
				};
				u16[] segID = {
					0,1,2,
					0,2,3
				};
				Render::RawTrianglesIndexed("hpsegment"+(i==0?"bottom":i==health-1?"top":"")+(b.getHealth()*4<=i?"empty":"")+".png", segV, segID);
			}
			//Ammo bar
			s8 max = b.get_s8("max_ammo");
			s8 ammo = b.get_s8("ammo");

			u32 bonus_time = b.get_u32("ammo_bonus");
			if (bonus_time > getGameTime())
			{
				max *= 2;
			}
			
			SColor ammo_color = color_white;
			if (ammo < max)
			{
				u32 time = b.get_u32("lastshot");
				u32 diff = getGameTime()-time;

				if (diff > 30)
				{
					u16 replenish_time = b.exists("replenish_time") ? b.get_u16("replenish_time") : 90;
					f32 blink = 255-Maths::Abs(Maths::Sin(f32(diff/(0.5f+(2-diff/(replenish_time/2)))))*(diff/2.0f));
					ammo_color.setRed(blink);
					ammo_color.setGreen(blink);
					ammo_color.setBlue(blink);
				}
			}

			for (u8 i = 0; i < max; i++)
			{
				Vertex[] segV = 
				{
					Vertex(40-segw, ScS.y-132-(segh+2)*i-segh, 0,	0, 0, ammo_color),
					Vertex(40+segw, ScS.y-132-(segh+2)*i-segh, 0,	1, 0, ammo_color),
					Vertex(40+segw, ScS.y-132-(segh+2)*i+segh, 0,	1, 1, ammo_color),
					Vertex(40-segw, ScS.y-132-(segh+2)*i+segh, 0,	0, 1, ammo_color)
				};
				u16[] segID = {
					0,1,2,
					0,2,3
				};
				Render::RawTrianglesIndexed("ammosegment"+(i==0?"bottom":i==max-1?"top":"")+(ammo<=i?"empty":"")+".png", segV, segID);
			}

			Render::SetAlphaBlend(false);
	
		}
	}
}

int index = 0;

void onTick(CRules@ rules)
{
	CBlob@ this = getLocalPlayerBlob();
	if (this is null) return;
	if (this.get_bool("stuck")) return;

	if(index > 0)
		index--;
	else if(index == 0 && this.getSprite().getFrame() == 24)
		index = 4;
	gun.SetFrame(index/2);
}