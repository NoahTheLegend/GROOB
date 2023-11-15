#include "TreeDeeMap.as";
#include "TreeDeeObjectsClass.as";
//#include "ThreeDeeNickNamesClass.as";
#include "TreeDeeCameraClass.as";
#include "ClientVars.as";

#define CLIENT_ONLY

float humanHeight = 0.75f;
float[] proj;
float[] model;
//float[] cam;

Camera cam;

void ComputeProjection(f32 fov, f32 ratio) {Matrix::MakePerspective(proj,fov,ratio,0.1f,100.0f);}

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Renders.as", "threedee", 0.0f);
	Render::addScript(Render::layer_postworld, "Renders.as", "worldcover", 0.0f); if(!Texture::exists("cover")) Texture::createFromFile("cover", "cover.png");
	Render::addScript(Render::layer_prehud, "RedFlash.as", "flash", 10.0f);
	Render::SetTransformScreenspace();
	Render::addScript(Render::layer_prehud, "GreenFlash.as", "flash", 10.0f);
	Render::SetTransformScreenspace();

	SetFov();
	//ThreeDeeMap@ three_dee_map = getThreeDeeMap();
}

void onTick(CRules@ this)
{
	if (this.hasTag("update_clientvars"))
	{
		SetFov();
	}

	// spectator mode
	CPlayer@ local = getLocalPlayer();
	if (local !is null)
	{
		if (local.getTeamNum() == getRules().getSpectatorTeamNum())
		{
			humanHeight = 20.0f;
			dir_y = -90;
		}
		else
		{
			humanHeight = 0.75f;
		}
	}
	else
		humanHeight = 0.75f;
}

void SetFov()
{
	f32 fov = min_fov;
    ClientVars@ vars;
    if (getRules().get("ClientVars", @vars))
    {
        fov = vars.fov_final;
    }
	f32 angle = Maths::Pi/(1.000000f+fov);
	CBlob@ local = getLocalPlayerBlob();
	if (local !is null)
	{
		local.set_f32("fov", Maths::Round(angle * 57.2958f));
	}
	ComputeProjection(angle, f32(getDriver().getScreenWidth()) / f32(getDriver().getScreenHeight()));
}

//float LastCameraAngleX = 0.01f;
//float LastCameraAngleY = 0.01f;
//float LastCameraAngleZ = 0.01f;

/*
void calcCamera(CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if(blob !is null)
	{
		CRules@ rules = getRules();
		if(rules !is null)
		{
			CControls@ c = getControls();
			Driver@ d = getDriver();
			if(!rules.get_bool("stuck") && d !is null && c !is null)
			{
				Vec2f ScrMid = Vec2f(f32(d.getScreenWidth()) / 2, f32(d.getScreenHeight()) / 2);
				Vec2f dir = (c.getMouseScreenPos() - ScrMid);
				f32 dirX = blob.get_f32("dir_x");
				f32 dirY = blob.get_f32("dir_y");
				dirX += dir.x;
				dirY = Maths::Clamp(dirY-dir.y,-90,90);
				blob.set_f32("dir_x", dirX);
				blob.set_f32("dir_y", dirY);
				c.setMousePosition(ScrMid);
			}
		}
	}
}
*/

Vec2f pos = Vec2f_zero;
Vec2f vel = Vec2f_zero;
f32 dir_x = 0.01f;
f32 dir_y = 0.01f;

void threedee(int id)
{
	CPlayer@ p = getLocalPlayer();
	if(p !is null)
	{
		// Default values
		//Vec2f pos = Vec2f_zero;
		//Vec2f vel = Vec2f_zero;
		//f32 dir_x = 0.01f;
		//f32 dir_y = 0.01f;
		
		// Getting camera position and angle
		CBlob@ b = p.getBlob();
		if(b !is null)
		{
			pos = b.getInterpolatedPosition()/16;
			vel = b.getVelocity();
			dir_x = b.get_f32("dir_x");
			dir_y = b.get_f32("dir_y");
		}
		
		// Calculating camera angles
		//float NewCameraAngleX = lerp(LastCameraAngleX, dir_x, getRenderApproximateCorrectionFactor());
		//float NewCameraAngleY = lerp(LastCameraAngleY, dir_y, getRenderApproximateCorrectionFactor());
		//float NewCameraAngleZ = lerp(LastCameraAngleZ, vel.RotateBy(-dir_x).y*1.3, getRenderApproximateCorrectionFactor()/4);
	
		f32 shake = 0.5f;
		s8 reverse = 1;
    	ClientVars@ vars;
    	if (getRules().get("ClientVars", @vars))
    	{
    	    shake = vars.cam_shake;
			reverse = vars.reverse_shake ? -1 : 1;
    	}
		f32 shake_mod = shake*4*reverse;

		cam.MoveCamera(	lerp(cam.LastCameraAngleX, dir_x, getRenderApproximateCorrectionFactor()), 
						lerp(cam.LastCameraAngleY, dir_y, getRenderApproximateCorrectionFactor()), 
						lerp(cam.LastCameraAngleZ, -vel.RotateBy(-dir_x).y*shake_mod, getRenderApproximateCorrectionFactor()/4));
		
		//LastCameraAngleX = NewCameraAngleX;
		//LastCameraAngleY = NewCameraAngleY;
		//LastCameraAngleZ = NewCameraAngleZ;
		
		//float[] tempH;
		//Matrix::MakeIdentity(tempH);
		//Matrix::SetRotationDegrees(tempH, 0, NewCameraAngleX, 0);
		//
		//float[] tempV;
		//Matrix::MakeIdentity(tempV);
		//Matrix::SetRotationDegrees(tempV, NewCameraAngleY, 0, 0);
		//
		//float[] tempR;
		//Matrix::MakeIdentity(tempR);
		//Matrix::SetRotationDegrees(tempR, 0, 0, NewCameraAngleZ);
		//
		//float[] tempCam;
		//Matrix::MakeIdentity(tempCam);
		//tempCam = Multiply(tempV, tempR);
		//
		//cam = Multiply(tempCam, tempH);
		
		Render::SetViewTransform(cam.matrix);
		
		Render::SetZBuffer(true, true);
		Render::ClearZ();
		Render::SetBackfaceCull(true);
		Render::SetProjectionTransform(proj);
		
		ThreeDeeMap@ three_dee_map = getThreeDeeMap();
		
		// Render sky
		Matrix::MakeIdentity(model);
		Matrix::SetTranslation(model, 0, 0, 0);
		Render::SetModelTransform(model);
		Render::RawTrianglesIndexed(three_dee_map.sky_texture, three_dee_map.skybox_Vertexes, three_dee_map.skybox_IDs);

		Render::ClearZ();
		
		Render::SetAlphaBlend(false);

		// Render map
		Matrix::MakeIdentity(model);
		Matrix::SetTranslation(model, -pos.y, -humanHeight, -pos.x);
		Render::SetModelTransform(model);
		Render::RawQuads(three_dee_map.map_tile_sheet, three_dee_map.Vertexes);
		
		// Render objects
		CBlob@[] blobs;
		getBlobs(blobs);
		for(int i = 0; i < blobs.length(); i++)
		{
			CBlob@ blob = blobs[i];
			if(blob !is null)
			{
				Object@ obj;
				blob.get("object", @obj);
				if(obj !is null)
				{
					if(blob.isMyPlayer()) continue;
					
					Matrix::MakeIdentity(model);
					Vec2f look_vec = (pos*16)-blob.getPosition();
					f32 look_dir = look_vec.getAngleDegrees();
					Matrix::SetRotationDegrees(model, 0, -180-look_dir, 0);
					Vec2f translated_pos = Vec2f(blob.getInterpolatedPosition().y/16-pos.y, blob.getInterpolatedPosition().x/16-pos.x);
					u8 id = blob.get_u8("prop_id");
					switch(id)
					{
						case 1:
						{
								CSprite@ sprite = blob.getSprite();
								if(sprite !is null)
								{
									f32 ybit = 1.0000f/4.0000f;
									f32 xbit = 1.0000f/8.0000f;
									u16 frame = sprite.getFrame();
									u8 u = frame/8;

									Vec2f Edir = Vec2f(1,0).RotateBy(blob.get_f32("dir_x"));
									Vec2f Cdir = Vec2f(1,0).RotateBy(Vec2f(pos.x*16-blob.getPosition().x, pos.y*16-blob.getPosition().y).getAngleDegrees());
									Edir.RotateBy(360-Cdir.getAngleDegrees());
									f32 newangl = Edir.getAngleDegrees()+22.5;
									u8 l = (newangl/45) % 8;

									Vertex[] edited_Vertexes = obj.Vertexes;

									edited_Vertexes[0].v = f32(u)*ybit;
									edited_Vertexes[1].v = edited_Vertexes[2].v = f32(u+1)*ybit;

									edited_Vertexes[1].u = (l+1)*xbit;
									edited_Vertexes[0].u = edited_Vertexes[2].u = l*xbit;
								}
								
								Matrix::SetTranslation(model, translated_pos.x, -humanHeight, translated_pos.y);
								Render::SetModelTransform(model);
								
								//Render::RawTrianglesIndexed(obj.tile_sheet, obj.Vertexes, obj.IDs);
								Render::RawTriangles(obj.tile_sheet, obj.Vertexes);
								
								if(b is null) break;
								if(blob.getTeamNum() != b.getTeamNum()) break;

								//CPlayer@ player = blob.getPlayer();
								//if(player !is null)
								//{
								//	NickName@ nick;
								//	blob.get("N_N", @nick);
								//	if(nick !is null)
								//	{
								//		Render::SetAlphaBlend(true);
								//		//Render::SetZBuffer(false, true);
								//		//Matrix::SetTranslation(model, translated_pos.x, 0.4, translated_pos.y);
								//		//Render::SetModelTransform(model);
								//		Render::RawTrianglesIndexed(nick.player_name, nick.Vertexes, nick.IDs);
								//		Render::SetAlphaBlend(false);
								//		//Render::SetZBuffer(true, true);
								//		break;
								//	}
								//	else
								//	{
								//		NickName new_nick = NickName(player.isBot() ? "Default Grobber" : player.getUsername());
								//		blob.set("N_N", @new_nick);
								//	}
								//}
								break;
							//}
						}
						case 2:
						{
							float[] model_copy = model;
							Matrix::MakeIdentity(model_copy);
							Matrix::SetRotationDegrees(model_copy, -dir_y, dir_x, 0);
							Matrix::SetTranslation(model_copy, blob.getInterpolatedPosition().y/16-pos.y, -humanHeight/2.5, blob.getInterpolatedPosition().x/16-pos.x);
							Render::SetModelTransform(model_copy);
							Vertex[] edited_Vertexes = obj.Vertexes;
							edited_Vertexes[0].v = 0.125f*blob.getSprite().getFrame();
							edited_Vertexes[1].v = edited_Vertexes[2].v = 0.125f*(blob.getSprite().getFrame()+1);
							Render::RawTriangles(obj.tile_sheet, edited_Vertexes);
							break;
						}
						default:
						{
							Matrix::SetTranslation(model, translated_pos.x, -humanHeight, translated_pos.y);
							Render::SetModelTransform(model);
							//Render::RawTrianglesIndexed(obj.tile_sheet, obj.Vertexes, obj.IDs);
							Render::RawTriangles(obj.tile_sheet, obj.Vertexes);
							break;
						}
					}
				}
			}
		}
	}
}

float lerp(float v0, float v1, float t)
{
	return (1 - t) * v0 + t * v1;
}																																																																																																				void worldcover(int id){CMap@ map = getMap();Render::SetTransformWorldspace();Vertex[] cover_Vertexes={Vertex(0,0,500,0,0,color_white),Vertex(map.tilemapwidth*16,0,500,1,0,color_white),Vertex(map.tilemapwidth*16,map.tilemapheight*16,500,1,1,color_white),Vertex(0,map.tilemapheight*16,500,0,1,color_white)};Render::RawQuads("cover",cover_Vertexes);}