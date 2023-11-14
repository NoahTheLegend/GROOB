// init file for storing consts and class props
const f32 min_fov = 0.25f;
const f32 max_fov = 4.0f;
const u8 crosshair_amt = 4;
const f32 min_crosshair_scale = 1.0f;
const f32 max_crosshair_scale = 4.0f;
const u8 crosshair_cols = 8;

class ClientVars {
    f32 fov;
    f32 fov_final;
    f32 cam_shake;
    bool reverse_shake;
    bool footsteps;
    bool ownfootsteps;
    f32 crosshair;
    u8 crosshair_final;
    f32 crosshair_scale;
    f32 crosshaircolor;
    u8 crosshaircolor_final;
    f32 mouse_sensitivity;
    
    ClientVars()
    {
        fov = 0.5f;
        fov_final = fov;
        cam_shake = 0.5f;
        reverse_shake = false;
        footsteps = true;
        ownfootsteps = true;
        crosshair = 0;
        crosshair_final = 0;
        crosshair_scale = 1.0f;
        crosshaircolor = 0;
        crosshaircolor_final = 0;
        mouse_sensitivity = 0;
    }
};