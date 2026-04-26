U0 DamageMario(){
 // ignore if already dying or transforming (prevents double hits)
 if(mario.dying || mario.transforming|| mario.invulnTimer > 0)
  return;

 // --- BIG -> SMALL ---
 if(mario.isBig != MARIO_SMALL){
  // reuse your transform system (this is correct architecture)
  mario.transforming = 1;
  mario.transformTimer = 30;
  mario.shrinking = 1;
  shrinkSoundActive = TRUE;
  mario.invulnTimer = 120; // 90 = ~1.5 seconds at 60fps
  mario.isBig = MARIO_BIG; // start state
  // your transformSeq should already step down if reused correctly

  return;
 }

 // --- SMALL -> DEAD ---
 mario.dying = 1;
 mario.deathTimer = 120;
 dyingSoundActive = TRUE;

 mario.vx = 0;
 mario.vy = -12; // initial jump impulse (tune this)

 // optional: lock direction
}

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
   powerUpSoundActive = TRUE;
   // trigger growth
   mario.transforming = 1;
   mario.transformTimer = 30;  // ~0.5 sec feel
   mario.shrinking = 0;

  }

  next:
 }
}
U0 CheckGoombaMario()
{
 I64 i;

 I64 marioBottom     = mario.y + MarioH();
 I64 marioPrevBottom = marioBottom - mario.vy;
 I64 marioCenter     = mario.x + MarioW()/2;
 I64 marioLeft  = mario.x;
 I64 marioRight = mario.x + MarioW();

 Goomba *stompTarget = NULL;

 for(i = 0; i < MAX_GOOMBAS; i++){

  if(!goombas[i].active || goombas[i].crushed)
   goto nextGoomba;

  // --- slightly reduced hurtbox (prevents edge deaths) ---
  I64 gx = goombas[i].x + 4;
  I64 gw = 24;

  if(mario.x + MarioW() < gx) goto nextGoomba;
  if(mario.x > gx + gw)       goto nextGoomba;
  if(mario.y + MarioH() < goombas[i].y) goto nextGoomba;
  if(mario.y > goombas[i].y + 32)       goto nextGoomba;

  // --- stomp test (position + horizontal tolerance) ---
  I64 goombaTop    = goombas[i].y;
  I64 goombaCenter = goombas[i].x + 16;
  I64 goombaLeft  = goombas[i].x;
  I64 goombaRight = goombas[i].x + 32;

  // compute min(right edges)
  I64 rightEdge = marioRight;
  if(goombaRight < rightEdge)
   rightEdge = goombaRight;
  
  // compute max(left edges)
  I64 leftEdge = marioLeft;
  if(goombaLeft > leftEdge)
   leftEdge = goombaLeft;
   
  // overlap width
  I64 overlap = rightEdge - leftEdge;
  Bool fromAbove =
   (marioPrevBottom <= goombaTop + 8) &&  // slightly more forgiving
   (marioBottom     >= goombaTop)     &&  // crossed top
   (overlap > 6);                         // require minimal foot contact
  if(fromAbove){
   // pick highest valid stomp
   if(!stompTarget || goombas[i].y < stompTarget->y){
    stompTarget = &goombas[i];
   }
  }

  nextGoomba:
  ;
 }

 // --- resolve stomp first ---
 if(stompTarget){
  stompTarget->crushed = 1;
  stompTarget->animTimer = 20;
  stompSoundActive=TRUE;
  // stronger bounce, clears nearby enemies
  mario.vy = -10;

  return;
 }

 // --- otherwise any overlap = damage ---
 for(i = 0; i < MAX_GOOMBAS; i++){

  if(!goombas[i].active || goombas[i].crushed)
   goto resolveNext;

  if(mario.x + MarioW() < goombas[i].x) goto resolveNext;
  if(mario.x > goombas[i].x + 32)       goto resolveNext;
  if(mario.y + MarioH() < goombas[i].y) goto resolveNext;
  if(mario.y > goombas[i].y + 32)       goto resolveNext;

  DamageMario();
  return;
  resolveNext:
 }
}
U0 HandleBlockHit(I64 tx, I64 ty)
{
 if(tx < 0 || tx >= clvl->w || ty < 0 || ty >= clvl->h)
  return;

 I64 idx = ty * clvl->w + tx;
 I64 t = clvl->tiles[idx];

 // only handle ? blocks
 if((t==TILE_Q_MUSHRM)
    && clvl->tileBounce[idx] == 0 
    && clvl->tileState[idx] == 0){
  clvl->tileState[idx] = 1; // mark used
  // spawn coin
  clvl->tileBounce[idx] = 0;
  clvl->tileBounceVel[idx] = -4;  // upward impulse   // start upward motion
  SpawnMushroom(tx*32,ty*32-6);
  powerUpAppearSoundActive = TRUE;
 }
 else if((t == TILE_QUESTION) 
    && clvl->tileBounce[idx] == 0 
    && clvl->tileState[idx] == 0){
  clvl->tileState[idx] = 1; // mark used
  // spawn coin
  clvl->tileBounce[idx] = 0;
  clvl->tileBounceVel[idx] = -4;  // upward impulse   // start upward motion
  SpawnCoin(tx * 32, ty * 32);
  coinSoundActive = TRUE;
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

