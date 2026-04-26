U0 SpawnCoin(I64 x, I64 y)
{
 I64 i;
 for(i = 0; i < MAX_COINS; i++){
  if(!coins[i].active){

   coins[i].active = 1;
   coins[i].x = x;
   coins[i].y = y;
   coins[i].vy = -15;     // shoot upward
   coins[i].timer = 30;   // lifetime

   break;
  }
 }
}

U0 SpawnMushroom(I64 x, I64 y)
{
 I64 i;
 for(i = 0; i < MAX_MUSHRM; i++){
  if(!mush[i].active){

   mush[i].active = 1;
   mush[i].x = x;
   mush[i].y = y;

   mush[i].targetY = y - 32;
   mush[i].vx = 0;     // start moving right
   mush[i].vy = -2;    // pop upward like mario
  
   mush[i].rising = 1;
   break;
  }
 }
}

U0 SpawnGoomba(I64 tx, I64 ty)
{
 I64 i;
 for(i = 0; i < MAX_GOOMBAS; i++){
  if(!goombas[i].active){
   goombas[i].active = 1;
   goombas[i].crushed = 0;

   goombas[i].x = tx * TILE_SIZE;
   goombas[i].y = ty * TILE_SIZE;

   goombas[i].vx = -1; // start moving left
   goombas[i].vy = 0;
   goombas[i].animTimer = 0;
   return;
  }
 }
}