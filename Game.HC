U0 SpawnCoin(I64 x, I64 y)
{
 I64 i;
 for(i = 0; i < MAX_COINS; i++){
  if(!coins[i].active){

   coins[i].active = 1;
   coins[i].x = x;
   coins[i].y = y;
   coins[i].vy = -12;     // shoot upward
   coins[i].timer = 30;   // lifetime

   break;
  }
 }
}
U0 UpdateCoins()
{
 I64 i;
 for(i = 0; i < MAX_COINS; i++){
  if(!coins[i].active) goto updateNext;
  coins[i].y += coins[i].vy;
  coins[i].vy += 1;   // gravity

  coins[i].timer--;
  if(coins[i].timer <= 0){
   coins[i].active = 0;
  }
  updateNext:
 }
}

U0 HandleBlockHit(I64 tx, I64 ty)
{
 if(tx < 0 || tx >= clvl->w || ty < 0 || ty >= clvl->h)
  return;

 I64 idx = ty * clvl->w + tx;
 U8 t = clvl->tiles[idx];

 // only handle ? blocks
 if((t == TILE_QUESTION || t==TILE_Q_MUSHRM) 
    && clvl->tileBounce[idx] == 0 && clvl->tileState[idx] == 0){
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

U0 UpdateTileBounce(){
I64 i;
 for(i = 0; i < clvl->w * clvl->h; i++){
  if(clvl->tileBounceVel[i] != 0 || clvl->tileBounce[i] != 0){
   clvl->tileBounce[i] += clvl->tileBounceVel[i];
   clvl->tileBounceVel[i] += 1; // gravity
   // clamp when it settles back
   if(clvl->tileBounce[i] > 0){
    clvl->tileBounce[i] = 0;
    clvl->tileBounceVel[i] = 0;
   }
  }
 }
}

U0 UpdateMario(){
 // --- Horizontal movement ---
 if(keyL){
  if(mario.vx > 0)
   mario.vx -= TURN_ACCEL;
  else
   mario.vx -= ACCEL;

  if(mario.vx < -MAX_SPEED)
   mario.vx = -MAX_SPEED;
 }
 else if(keyR){
  if(mario.vx < 0)
   mario.vx += TURN_ACCEL;
  else
   mario.vx += ACCEL;

  if(mario.vx > MAX_SPEED)
   mario.vx = MAX_SPEED;
 }
 else{
  if(mario.vx > 0){
   mario.vx -= FRICTION;
   if(mario.vx < 0) mario.vx = 0;
  }
  else if(mario.vx < 0){
   mario.vx += FRICTION;
   if(mario.vx > 0) mario.vx = 0;
  }
 }

 // --- Jump buffer ---
 if(keyJump && !jumpHeld){
  jumpBuffer = JUMP_BUFFER_FRAMES;
 }
 jumpHeld = keyJump;


 // --- Gravity ---
 mario.vy += GRAVITY;
 if(mario.vy > MAX_FALL) mario.vy = MAX_FALL;

 // --- variable jump height (early release) ---
 if(!keyJump && mario.vy < 0){
  if(mario.vy < -6)   // only cut if still moving up fast
   mario.vy = -6;
 }
 // --- Apply movement ---
 mario.x += mario.vx;
 // --- world bounds (LEFT WALL) ---
 if(mario.x < camX){
  mario.x = camX;
  mario.vx = 0;
 }

 // --- vertical collision ---
 I64 left   = WorldToTile(mario.x);
 I64 right  = WorldToTile(mario.x + 23);
 I64 top    = WorldToTile(mario.y);
 I64 bottom = WorldToTile(mario.y + 31);
 // moving right
 if(mario.vx > 0){
  if(IsSolidTile(right, top) || IsSolidTile(right, bottom)){
   mario.x = right * TILE_SIZE - 32;
   mario.vx = 0;
  }
 }
 // moving left
 else if(mario.vx < 0){
  if(IsSolidTile(left, top) || IsSolidTile(left, bottom)){
   mario.x = (left + 1) * TILE_SIZE;
   mario.vx = 0;
  }
 }
 mario.y += mario.vy;

 left   = WorldToTile(mario.x);
 right  = WorldToTile(mario.x + 23);
 top    = WorldToTile(mario.y);
 bottom = WorldToTile(mario.y + 31);
 // falling
 if(mario.vy > 0){
  if(IsSolidTile(left, bottom) || IsSolidTile(right, bottom)){
   mario.y = bottom * TILE_SIZE - 32;
   mario.vy = 0;
  }
 }
 // jumping
 else if(mario.vy < 0){
  I64 hitY = top;
  I64 hitX1 = left;
  I64 hitX2 = right;
  if(IsSolidTile(hitX1, hitY) || IsSolidTile(hitX2, hitY)){
   // handle ? blocks
   HandleBlockHit(hitX1, hitY);
   if(hitX2 != hitX1)
    HandleBlockHit(hitX2, hitY);

   mario.y = (top + 1) * TILE_SIZE;
   mario.vy = 0;
  }
 }

 //recompute AFTER correction
 bottom = WorldToTile(mario.y + 31);
 //if( mario.vy >=0){
  grounded =
   IsSolidTile(left,  WorldToTile(mario.y + 32)) ||
   IsSolidTile(right, WorldToTile(mario.y + 32));
 //}
 if(jumpBuffer > 0 && grounded){
  mario.vy = JUMP_VEL;
  jumpBuffer = 0;

  jumpSoundActive = 1;
 }

 if(jumpBuffer > 0) jumpBuffer--;

 // --- Direction follows velocity ---
 if(mario.vx < 0) mario.dir = DIR_L;
 if(mario.vx > 0) mario.dir = DIR_R;

 // --- State resolution (ONLY place state is set) ---
 if(!grounded){
  if(mario.vy < 0)
   mario.state = ST_JUMP;
  else
   mario.state = ST_FALL;
 }
 else{
  // trigger turn
  if(mario.turnTimer == 0 &&
   ((keyL && mario.vx > 1) || (keyR && mario.vx < -1))){
 
   mario.turnTimer = TURN_TIME;
   mario.turnDir = mario.dir; // LOCK direction at start of skid
  }  
  // lock turn state while timer active
  if(mario.turnTimer > 0){
   mario.state = ST_TURN;
   mario.turnTimer--;
  }
  else if(mario.vx == 0){
   mario.state = ST_IDLE;
  }
  else{
   mario.state = ST_WALK;
  }
 }
 // follow Mario to the right
 I64 targetCam = camX;
 if(mario.x - camX > SCREEN_W - CAMERA_MARGIN){
  targetCam = mario.x - (SCREEN_W - CAMERA_MARGIN);
 }

 if(targetCam > camX){
  camX= targetCam;
 }

 // clamp camera
 if(camX < 0) camX = 0;

 I64 maxCam = clvl->w * TILE_SIZE - SCREEN_W;
 if(camX > maxCam) camX = maxCam;
}

