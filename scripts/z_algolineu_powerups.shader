flamethrower_particle
{
	cull none
	nopicmip
	entityMergable
	softParticle
	{
		clampmap gfx/misc/rlexplo4
		blendFunc add
		rgbGen const 1 .5 0
		alphaGen vertex
	}
}