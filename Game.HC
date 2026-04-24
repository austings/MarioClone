U0 CheckMushroomPickup()
{
 I64 i;
 for(i = 0; i < MAX_MUSHRM; i++){
  if(!mush[i].active) goto next;

  // skip while emerging (optional but cleaner)
  if(mush[i].rising) goto next;

  if(AABBOverlap(
     mario.x, mario.y, 24, 32,
     mush[i].x, mush[i].y, 32, 32))
  {
   mush[i].active = 0;

   // trigger growth
   mario.transforming = 1;
   mario.transformTimer = 30;  // ~0.5 sec feel

  }

  next:
 }
}
U0 HandleBlockHit(I64 tx, I64 ty)
{
 if(tx < 0 || tx >= clvl->w || ty < 0 || ty >= clvl->h)
  return;

 I64 idx = ty * clvl->w + tx;
 U8 t = clvl->tiles[idx];

 // only handle ? blocks
 if((t==TILE_Q_MUSHRM)
    && clvl->tileBounce[idx] == 0 
    && clvl->tileState[idx] == 0){
  clvl->tileState[idx] = 1; // mark used
  // spawn coin
  clvl->tileBounce[idx] = 0;
  clvl->tileBounceVel[idx] = -4;  // upward impulse   // start upward motion
  SpawnMushroom(tx*32,ty*32-6);
 }
 else if((t == TILE_QUESTION) 
    && clvl->tileBounce[idx] == 0 
    && clvl->tileState[idx] == 0){
  clvl->tileState[idx] = 1; // mark used
  // spawn coin
  clvl->tileBounce[idx] = 0;
  clvl->tileBounceVel[idx] = -4;  // upward impulse   // start upward motion
  SpawnCoin(tx * 32, ty * 32);
 }
 // --- BRICK BLOCKS ---
 else if(t == TILE_BRICK &&
         clvl->tileBounce[idx] == 0){

  // small Mario just bounce
  if(!mario.isBig){
    clvl->tileBounce[idx] = 0;
    clvl->tileBounceVel[idx] = -4;
  }
  else{
    // big Mario placeholder for break logic
    // for now just bounce so can verify
    clvl->tileBounce[idx] = 0;
    clvl->tileBounceVel[idx] = -4;

    // later:
    // clvl->tiles[idx] = 0;
    // SpawnBrickParticles(...)
  }
 }
}
