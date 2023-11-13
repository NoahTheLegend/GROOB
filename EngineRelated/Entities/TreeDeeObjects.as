//TreeDeeObjects.as

#include "IsLocalhost.as"
#include "TreeDeeMap.as"
#include "TreeDeeObjectsClass.as"

void onInit(CBlob@ this)
{
	if(isClient() || isLocalhost())
	{
		//if(this.getPlayer().isMyPlayer()) return;
		if(this.getConfig() == "box")
		{
			ThreeDeeMap@ three_dee_map = getThreeDeeMap();
			if(three_dee_map !is null)
			{
				//print("box");
				Vec2f intPos = this.getPosition()/8;
				Vertex[] Vertexes = {	Vertex(-0.25, 1.0, 0, 0,0,three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
										Vertex(0.75, 0.0, 0, 1,1,three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
										Vertex(-0.25, 0.0, 0, 0,1,three_dee_map.lightMapImage.get(intPos.x, intPos.y))};
				string tile_sheet = "box.png";
				Object obj = Object(tile_sheet, Vertexes);
				this.set("object", @obj);
			}
			//u16[] IDs = {0,1,2};
		}
		
		else if(this.getConfig() == "barrel")
		{
			ThreeDeeMap@ three_dee_map = getThreeDeeMap();
			if(three_dee_map !is null)
			{
				//print("box");
				Vec2f intPos = this.getPosition()/8;
				Vertex[] Vertexes = {	Vertex(-0.25, 1.0, 0, 0,0,three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
										Vertex(0.75, 0.0, 0, 1,1,three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
										Vertex(-0.25, 0.0, 0, 0,1,three_dee_map.lightMapImage.get(intPos.x, intPos.y))};
				string tile_sheet = "barrel.png";
				Object obj = Object(tile_sheet, Vertexes);
				this.set("object", @obj);
			}
			//u16[] IDs = {0,1,2};
		}
		
		else if(this.getConfig() == "player")
		{
			ThreeDeeMap@ three_dee_map = getThreeDeeMap();
			if(three_dee_map !is null)
			{
				//print("box");
				Vec2f intPos = this.getPosition()/8;
				Vertex[] Vertexes = {	Vertex(-0.5, 2.0, 0, 	0,0,	three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
										Vertex(1.5, 0.0, 0, 	0.125,0.25,	three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
										Vertex(-0.5, 0.0, 0, 	0,0.25,	three_dee_map.lightMapImage.get(intPos.x, intPos.y))};
				string tile_sheet = "Player"+this.getTeamNum()+".png";
				Object obj = Object(tile_sheet, Vertexes);
				this.set("object", @obj);
			}
			//u16[] IDs = {0,1,2};
		}
		
		else if(this.getConfig() == "bullet")
		{
			ThreeDeeMap@ three_dee_map = getThreeDeeMap();
			if(three_dee_map !is null)
			{
				//print("box");
				Vec2f intPos = this.getPosition()/8;
				Vertex[] Vertexes = {	Vertex(-0.1875, 	0.609375, 0, 	0,		0,		color_white),
										Vertex(0.625, 		-0.203125, 0, 	1, 		0.125,	color_white),
										Vertex(-0.1875, 	-0.203125, 0, 	0, 		0.125,	color_white)};
				string tile_sheet = "bullet"+this.getTeamNum()+".png";
				Object obj = Object(tile_sheet, Vertexes);
				this.set("object", @obj);
			}
			//u16[] IDs = {0,1,2};
		}
	}
}

void onTick(CBlob@ this)
{
	if(isClient() || isLocalhost())
	{
		if(this.getShape().isStatic() || this.getConfig() == "bullet") return;
		if(this.isMyPlayer()) return;
		ThreeDeeMap@ three_dee_map = getThreeDeeMap();
		if(three_dee_map !is null)
		{
			Object@ obj;
			this.get("object", @obj);
			if(obj !is null)
			{
				Vec2f intPos = this.getPosition()/8;
				//Vertex[] Vertexes = obj.Vertexes;
				for(int i = 0; i < obj.Vertexes.length(); i++)
				{
					obj.Vertexes[i].col = three_dee_map.lightMapImage.get(intPos.x, intPos.y);
				}
			}
			this.set("object", @obj);
			/*
			Vec2f intPos = this.getPosition()/16*3;
			Vertex[] Vertexes = {	Vertex(-0.25, 1.0, 0, 0,0,three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
									Vertex(0.75, 0.0, 0, 1,1,three_dee_map.lightMapImage.get(intPos.x, intPos.y)),
									Vertex(-0.25, 0.0, 0, 0,1,three_dee_map.lightMapImage.get(intPos.x, intPos.y))};
			string tile_sheet = "box.png";
			Object obj = Object(tile_sheet, Vertexes);
			this.set("object", @obj);*/
		}
	}
}

/*
dictionary getThreeDeeObjectsHolder()
{
	dictionary@ three_dee_objects_holder;
	getRules().get("ThreeDeeObjectsHolder", @three_dee_objects_holder);
	return three_dee_objects_holder;
}

class Object
{
	Vertex[] Vertexes;
	u16[] IDs;
	Object(){}
	Object(Vertex[] _Vertexes, u16[] _IDs)
	{
		Vertexes = _Vertexes;
		IDs = _IDs;
	}
}
*/