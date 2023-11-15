#define CLIENT_ONLY

#include "ClientVars.as";
#include "ClientConfig.as";

u8 type = 3;
SColor col = SColor(255,255,0,0);
f32 scale = 0;
f32 sensitivity = 0.5f;

void onInit(CRules@ this)
{
    if (isClient())
	{
        // init
        ClientVars setvars();
	    this.set("ClientVars", @setvars);

		ClientVars@ vars;
        if (this.get("ClientVars", @vars))
        {
            LoadConfig(this, vars);

            // tagging for update doesnt work dont get bothered spending another hour for this shit
            type = vars.crosshair_final;
            col = getCrosshairColor(vars.crosshaircolor_final);
            scale = vars.crosshair_scale;
            updateRulesProps(this);
        }

        SetupUI(this);
    }
}
/*
#ifdef STAGING
void onTick(CRules@ this)
{
    ClientVars@ vars;
    if (this.get("ClientVars", @vars))
    {
        LoadConfig(this, vars);
    }
}
#endif
*/
void onRestart(CRules@ this)
{
    if (isClient() && isServer() && getLocalPlayer() !is null)
        onInit(this);

    updateRulesProps(this);
}

void updateRulesProps(CRules@ this)
{
    this.set_u8("crosshair", type);
    this.set_u8("c_red", col.getRed());
    this.set_u8("c_green", col.getGreen());
    this.set_u8("c_blue", col.getBlue());
    this.set_f32("crosshair_scale", scale);
    this.set_f32("sensitivity", sensitivity);
}

// hack
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
    if (player !is null && player.isMyPlayer())
    {
        updateRulesProps(this);
    }
}

void LoadConfig(CRules@ this, ClientVars@ vars) // load cfg from cache
{
    ConfigFile cfg = ConfigFile();

	if (!cfg.loadFile("../Cache/groobclientconfig.cfg"))
	{
        // set default vars if file wasnt loaded
        error("Client config or vars could not load");
        //====================================================
        cfg.add_f32("fov", 0.2f);
        cfg.add_f32("cam_shake", 0.25f);
        cfg.add_bool("reverse_shake", false);
        cfg.add_bool("footsteps", true);
        cfg.add_bool("ownfootsteps", true);
        cfg.add_f32("crosshair", 0);
        cfg.add_f32("crosshair_scale", 0.1f);
        cfg.add_f32("crosshair_color", 0);
        cfg.add_f32("mouse_sensitivity", 0.5f);
        //====================================================

		cfg.saveFile("groobclientconfig.cfg");
	}
    else if (vars !is null)
    {
        // insert vars
        //====================================================
        vars.fov = cfg.read_f32("fov", 0.2f);
        vars.fov_final = min_fov + vars.fov*max_fov;
        vars.cam_shake = cfg.read_f32("cam_shake", 0.25f);
        vars.reverse_shake = cfg.read_bool("reverse_shake", false);
        vars.footsteps = cfg.read_bool("footsteps", true);
        vars.ownfootsteps = cfg.read_bool("ownfootsteps", true);
        vars.crosshair = cfg.read_f32("crosshair");
        vars.crosshair_final = Maths::Round(vars.crosshair*(crosshair_amt-1));
        vars.crosshair_scale = cfg.read_f32("crosshair_scale");
        vars.crosshaircolor = cfg.read_f32("crosshair_color", 0);
        vars.crosshaircolor_final = Maths::Round(vars.crosshaircolor*(crosshair_cols-1));
        vars.mouse_sensitivity = cfg.read_f32("mouse_sensitivity", 0.5f);
        //====================================================
    }
}

void SetupUI(CRules@ this) // add options here
{
    Vec2f menu_pos = Vec2f(15,150);
    Vec2f menu_dim = Vec2f(415, 500);
    ConfigMenu setmenu(menu_pos, menu_dim);
    
    Vec2f quarter = Vec2f(menu_dim.x/2, menu_dim.y/2);

    // keep order with saving vars
    ClientVars@ vars;
    if (getRules().get("ClientVars", @vars))
    {
        //====================================================
        Vec2f section_pos = menu_pos;
        Section camera("Camera", section_pos, quarter);
        
        // name, pos, slider, checkbox
        Option sensitivity("Mouse sensitivity", section_pos+camera.padding+Vec2f(0,40), true, false);
        sensitivity.slider.setSnap(10);
        sensitivity.setSliderPos(vars.mouse_sensitivity);
        sensitivity.setSliderTextMode(1);

        Option fov("Field of view", sensitivity.pos+Vec2f(0,40), true, false);
        fov.setSliderPos(vars.fov);
        fov.setSliderTextMode(2);

        Option camshake("Camera lean", fov.pos+Vec2f(0,45), true, false);
        camshake.setSliderPos(vars.cam_shake);

        Option revshake("Reverse lean side", camshake.pos+Vec2f(0,50), false, true);
        revshake.setCheck(vars.reverse_shake);

        camera.addOption(sensitivity);
        camera.addOption(fov);
        camera.addOption(camshake);
        camera.addOption(revshake);

        setmenu.addSection(camera);

        Section sound("Sounds", section_pos+Vec2f(0, menu_dim.y/2), quarter);

        Option footsteps("Other footsteps", sound.pos+Vec2f(15,50), false, true);
        footsteps.setCheck(vars.footsteps);

        Option ownfootsteps("Your footsteps", footsteps.pos+Vec2f(0,30), false, true);
        ownfootsteps.setCheck(vars.ownfootsteps);

        sound.addOption(footsteps);
        sound.addOption(ownfootsteps);
        
        setmenu.addSection(sound);

        Section other("Crosshair", section_pos+Vec2f(menu_dim.x/2, 0), quarter);
        
        Option crosshair("Crosshair", other.pos+Vec2f(15, 45), true, false);
        crosshair.slider.setSnap(crosshair_amt);
        crosshair.setSliderPos(vars.crosshair);
        crosshair.setSliderTextMode(1);

        Option crosshaircol("Crosshair color", crosshair.pos+Vec2f(0, 45), true, false);
        crosshaircol.slider.setSnap(crosshair_cols);
        crosshaircol.setSliderPos(vars.crosshaircolor);
        crosshaircol.setSliderTextMode(1);

        Option crosshairscale("Crosshair scale", crosshaircol.pos+Vec2f(0, 45), true, false);
        crosshairscale.setSliderPos(vars.crosshair_scale);

        other.addOption(crosshair);
        other.addOption(crosshaircol);
        other.addOption(crosshairscale);

        setmenu.addSection(other);
        //====================================================
    }
    else error("Could not setup config UI, clientvars do not exist");

	this.set("ConfigMenu", @setmenu);
}

void WriteConfig(CRules@ this, ConfigMenu@ menu) // save config
{
    if (menu is null)
    {
        error("Could not save vars, menu is null");
        return;
    }

    ClientVars@ vars;
    if (getRules().get("ClientVars", @vars))
    {
        CBlob@ local = getLocalPlayerBlob();
        if (local !is null)
        {
            Option@ fov = menu.sections[0].options[1];
            if (fov !is null)
            {
                fov.slider.description = local.get_f32("fov")<140?""+local.get_f32("fov"):"Quake pro";
            }
        }

        //camera
        //====================================================
        if (menu.sections.size()!=0)
        {
            if (menu.sections[0].options.size()!=0)
            {
                Option sensitivity = menu.sections[0].options[0];
                vars.mouse_sensitivity = sensitivity.slider.scrolled;

                Option fov = menu.sections[0].options[1];
                vars.fov = fov.slider.scrolled;
                vars.fov_final = min_fov + vars.fov*max_fov;

                Option camshake = menu.sections[0].options[2];
                vars.cam_shake = camshake.slider.scrolled;

                Option revshake = menu.sections[0].options[3];
                vars.reverse_shake = revshake.check.state;
            }

            if (menu.sections[1].options.size()!=0)
            {
                //sound
                Option footsteps = menu.sections[1].options[0];
                vars.footsteps = footsteps.check.state;

                Option ownfootsteps = menu.sections[1].options[1];
                vars.ownfootsteps = ownfootsteps.check.state;
            }

            if (menu.sections[2].options.size()!=0)
            {
                //other
                Option crosshairtype = menu.sections[2].options[0];
                vars.crosshair = crosshairtype.slider.scrolled;
                vars.crosshair_final = Maths::Round(vars.crosshair*(crosshair_amt-1));

                Option crosshaircol = menu.sections[2].options[1];
                vars.crosshaircolor = crosshaircol.slider.scrolled;
                vars.crosshaircolor_final = Maths::Round(vars.crosshaircolor*(crosshair_cols-1));

                Option crosshairscale = menu.sections[2].options[2];
                vars.crosshair_scale = crosshairscale.slider.scrolled;
            }
        
        
            //====================================================
            ConfigFile cfg = ConfigFile();
	        if (cfg.loadFile("../Cache/groobclientconfig.cfg"))
	        {
                // write config
                //====================================================
                cfg.add_f32("fov", vars.fov);
                cfg.add_f32("cam_shake", vars.cam_shake);
                cfg.add_bool("reverse_shake", vars.reverse_shake);
                cfg.add_bool("footsteps", vars.footsteps);
                cfg.add_bool("ownfootsteps", vars.ownfootsteps);
                cfg.add_f32("crosshair", vars.crosshair);
                cfg.add_f32("crosshair_scale", vars.crosshair_scale);
                cfg.add_f32("crosshair_color", vars.crosshaircolor);
                cfg.add_f32("mouse_sensitivity", vars.mouse_sensitivity);
                //====================================================
                // save config
	        	cfg.saveFile("groobclientconfig.cfg");
	        }
            else
            {
                error("Could not load config to save vars code 1");
                error("Loading default preset");
                //====================================================
                cfg.add_f32("fov", 0.2f);
                cfg.add_f32("cam_shake", 0.25f);
                cfg.add_bool("reverse_shake", false);
                cfg.add_bool("footsteps", true);
                cfg.add_bool("ownfootsteps", true);
                cfg.add_f32("crosshair", 0);
                cfg.add_f32("crosshair_scale", 0.1f);
                cfg.add_f32("crosshair_color", 0);
                cfg.add_f32("mouse_sensitivity", 0.5f);
                //====================================================

		        cfg.saveFile("groobclientconfig.cfg");
            }
        }
        else error("Could not load config to save vars code 2");
    }
}

void onRender(CRules@ this) // renderer for class, saves config if class throws update tag
{
    if (isClient())
    {
        bool need_update = this.hasTag("update_clientvars");
        
        ConfigMenu@ menu;
        if (this.get("ConfigMenu", @menu))
        {
            menu.render();
            if (menu.state == 0) GUI::DrawText("SETTINGS\nRCTRL\n(TAB IF STAGING)", menu.pos+Vec2f(0,32), SColor(155,255,255,0));
            if (need_update)
            {
                WriteConfig(this, menu);
            }
        }

        // put common stuff to update here, otherwise keep in relative scripts
        if (need_update)
        {
		    ClientVars@ vars;
    	    if (this.get("ClientVars", @vars))
    	    {
    	        type = vars.crosshair_final;
                col = getCrosshairColor(vars.crosshaircolor_final);
                scale = vars.crosshair_scale;
                sensitivity = vars.mouse_sensitivity;
                updateRulesProps(this);
    	    }
        }
    }
}

SColor getCrosshairColor(u8 type)
{
    switch (type)
    {
        case 0: {return SColor(255,255,0,0);}
        case 1: {return SColor(255,0,255,0);}
        case 2: {return SColor(255,85,85,255);}
        case 3: {return SColor(255,255,255,0);}
        case 4: {return SColor(255,0,255,255);}
        case 5: {return SColor(255,255,0,255);}
        case 6: {return SColor(255,155,155,155);}
        case 7: {return SColor(255,255,255,255);}
    }
    return color_white;
}