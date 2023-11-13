const f32 DASH_COOLDOWN = 45; // dont set lower than dash time
const f32 DASH_TIME = 15; // how long to boost
const f32 DASH_MOD = 6.5f; // boost power
const f32 max_vel = 1.25f;
const f32 base_friction = 0.25f; // friction to overall movement from inbetween 0 and 1
const f32 movement_friction = 4; // modifies how much friction you have while changing movement velocity

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	CBlob@ blob = this.getBlob();
	CShape@ shape = blob.getShape();
	shape.SetGravityScale(0.0f);
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob is null || !blob.isMyPlayer()) return;
	CControls@ c = blob.getControls();

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	const bool shift	= c.isKeyPressed(KEY_LSHIFT);

	Vec2f force;
	f32 pow = 1.0f;
	// movement
	if (up)
	{
		force.x += pow;
	}

	if (down)
	{
		force.x -= pow;
	}

	if (left)
	{
		force.y -= pow;
	}

	if (right)
	{
		force.y += pow;
	}

	bool release = !left && !right && !up && !down;
	force.Normalize();
	f32 dirX = blob.get_f32("dir_x");
	force.RotateBy(dirX);

	f32 dash_cd = blob.get_u32("dash_cd");
	bool dash = shift && dash_cd < getGameTime();

	if (dash)
	{
		blob.set_u32("dash_cd", getGameTime() + DASH_COOLDOWN);
		force *= DASH_MOD;
	}

	f32 rem = dash_cd > getGameTime() ? dash_cd - getGameTime() : 0;
	f32 dash_factor = (DASH_COOLDOWN-Maths::Max(rem, DASH_COOLDOWN-DASH_TIME)) / DASH_TIME;
	blob.AddForce(force*movement_friction*dash_factor);

	//damp vel
	Vec2f vel = blob.getVelocity();
	f32 vellen = Maths::Abs(vel.Length());
	f32 actual_mod = Maths::Max(base_friction, dash_factor);
	if (vellen > max_vel/actual_mod)
	{
		vel *= Maths::Max(0.05, max_vel/vellen)/actual_mod;
		//printf(vellen+"|"+max_vel+"|"+(vellen-max_vel));
	}
	if (release)
	{
		vel *= 1.0f - base_friction;
	}
	blob.setVelocity(vel);
}