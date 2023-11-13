//TreeDeeObjectsClass.as

class Object
{
	string tile_sheet;
	Vertex[] Vertexes;
	//u16[] IDs;
	Object(){}
	Object(string _tile_sheet, Vertex[] _Vertexes)
	{
		tile_sheet = _tile_sheet;
		Vertexes = _Vertexes;
		//IDs = _IDs;
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