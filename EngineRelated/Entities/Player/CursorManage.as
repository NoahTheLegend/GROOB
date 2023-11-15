#define CLIENT_ONLY

void onInit(CSprite@ this)
{
	//this.getCurrentScript().runFlags |= Script::tick_myplayer; // broken on staging?
	//this.getCurrentScript().removeIfTag = "dead";
}

void ManageCursors(CBlob@ this)
{
	if (getHUD().hasButtons() || this.get_bool("stuck"))
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		getHUD().SetCursorImage("HideCursor.png");
	}
	
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer()) return;
	ManageCursors(blob);
}
