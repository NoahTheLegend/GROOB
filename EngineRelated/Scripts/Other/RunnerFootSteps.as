#define CLIENT_ONLY

#include "RunnerCommon.as"
#include "ClientVars.as";
#include "TreeDeeSound.as"

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();

	// this.getCurrentScript().runFlags |= Script::tick_onground;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater;
	this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

    bool other = true;
    bool own = true;
    ClientVars@ vars;
    if (getRules().get("ClientVars", @vars))
    {
        other = vars.footsteps;
        own = vars.ownfootsteps;
    }
    bool mp = blob.isMyPlayer();

    if (other || (own && mp))
    {
        if (!own && mp) return;

        f32 vel = blob.getShape().vellen;
	    if (vel > 0.1f)
	    {
	    	if ((blob.getNetworkID() + getGameTime()) % Maths::Max(4,Maths::Round(10-vel)) == 0)
	    	{
	    		//TileType tile = blob.getMap().getTile(blob.getPosition()).type;

	    		//if (blob.getMap().isTileGroundStuff(tile))
	    		//{
	    		//	this.PlayRandomSound("/EarthStep", volume);
	    		//}
	    		{
                    f32 walk_pitch = blob.get_f32("pitch");

                    PlayTreeDeeSound("gravel"+XORRandom(10), blob.getPosition(), 1.0f, walk_pitch + XORRandom(11)*0.01f);
	    		}
	    	}
	    }
    }
}