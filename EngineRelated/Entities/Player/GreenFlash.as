
#define CLIENT_ONLY

float alpha = 0;

u16[] IDs = {0, 1, 2, 0, 2, 3};

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (isClient() && this.isMyPlayer() && this.getHealth() > oldHealth)
	{
		SetScreenFlash( 0, 255, 255, 255 );
		alpha = 75;
    }
}


void flash(int id)
{
	if(alpha > 0.3)
	{
		Vertex[] Vertexes = {
			Vertex(0,0,0,0,0,SColor(Maths::Clamp(alpha, 0, 255), 255, 255, 255)),
			Vertex(getScreenWidth(),0,0,1,0,SColor(Maths::Clamp(alpha, 0, 255), 255, 255, 255)),
			Vertex(getScreenWidth(),getScreenHeight(),0,1,1,SColor(Maths::Clamp(alpha, 0, 255), 255, 255, 255)),
			Vertex(0,getScreenHeight(),0,0,1,SColor(Maths::Clamp(alpha, 0, 255), 255, 255, 255))
		};
		Render::SetTransformScreenspace();
		Render::RawTrianglesIndexed("Heal.png", Vertexes, IDs);
		Render::SetTransformScreenspace();
		alpha -= getRenderApproximateCorrectionFactor()*3;
	}
	//else if (alpha != 0)
	//{
	//	alpha = 0;
	//}
}