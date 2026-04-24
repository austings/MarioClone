U0 DrawCoins(CDC *dc)
{
 I64 i;
 for(i = 0; i < MAX_COINS; i++){
  if(!coins[i].active) goto nextCoins;
  // simple animation based on timer
  I64 f = (coins[i].timer / 5) % 3;

  CDC* spr;
  if(f == 0) spr = C3;
  else if(f == 1) spr = C2;
  else spr = C5;

  GrBlot3(dc, coins[i].x - camX, coins[i].y, 0, spr);
  nextCoins:
 }
}

CDC* GetMarioSprite()
{
 mario.animTimer++;

 switch(mario.state){

  case ST_IDLE:
   if(mario.dir==DIR_L) 
    return ONEL;
   else
    return ONER;

  case ST_WALK:
   if(mario.animTimer > 6){
    mario.frame = (mario.frame + 1) % 3;
    mario.animTimer = 0;
   }

   if(mario.dir == DIR_L){
    if(mario.frame==0) return TWOL;
    if(mario.frame==1) return THREEL;
    return FOURL;
   } else {
    if(mario.frame==0) return TWOR;
    if(mario.frame==1) return THREER;
    return FOURR;
   }

  case ST_TURN:
   if(mario.turnDir==DIR_L)
    return FIVEL;
   else
    return FIVER;

  case ST_JUMP:
  case ST_FALL:
   if(mario.dir==DIR_L)
    return SIXL; 
   else
    return SIXR;
 }

 return ONER;
}

U0 DrawMarioGame(CTask *task, CDC *dc)
{
 I64 x, y, idx, by;
 I64 startX = camX / TILE_SIZE;
 I64 endX = (camX + SCREEN_W) / TILE_SIZE + 1;

 // --- Background ---
 dc->color = BLUE;
 GrRect(dc,0,0,640,480);
 GrBlot3(dc,0,96,0,SPRITEBG);


 // --- Draw level tiles ---
 for(y = 0; y < clvl->h; y++){
  for(x = startX; x < endX; x++){
   switch(clvl->tiles[y * clvl->w + x]){

   case TILE_GROUND: // floor
    GrBlot3(dc, x*32 - camX, y*32, 0, FLOOR1);
    break;

   case TILE_BRICK:
    idx = y * clvl->w + x;
    by = clvl->tileBounce[idx];
    GrBlot3(dc, x*32 - camX, y*32 + by, 0, FLOOR2);
    break;
  
   case TILE_QUESTION: // ? block (coin)
   case TILE_Q_MUSHRM: // ? block (mushroom)
    idx = y * clvl->w + x;
    by = clvl->tileBounce[idx];
    if(clvl->tiles[idx] == 3 || clvl->tiles[idx] == 4){
     if(clvl->tileState[idx] == 0){ // unused block
      // simple global animation timer
      I64 f = (mario.animTimer / 10) % 5;
      CDC* spr;
      if(f == 0) spr = Q1;
      else if(f == 1) spr = Q2;
      else if(f == 2) spr = Q3;
      else if(f == 3) spr = Q2;
      else spr = Q1;
      GrBlot3(dc, x*32 - camX, y*32 +by, 0, spr);
     }
     else{
      // used block
      GrBlot3(dc, x*32 - camX, y*32 +by, 0, Q4);
     }
    }
    break;
   }
  }
 }
 UpdateTileBounce();
 UpdateCoins();  
 UpdateMario();
 DrawCoins(dc);
 CDC* player = GetMarioSprite();
 GrBlot3(dc,mario.x -camX,mario.y,0,player);
}

