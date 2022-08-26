#include "src/game/envfx_snow.h"

const GeoLayout balloon_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ASM(0, geo_mario_set_player_colors),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, balloon_balloon_mesh_layer_5),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, balloon_balloon_mesh_layer_1),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, balloon_material_revert_render_settings),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, balloon_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
