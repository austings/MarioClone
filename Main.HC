#include "Wad.HC";
#include "Globals.HC";
#include "Level.HC";

U0 UpdateMario()
{
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

 if(jumpBuffer > 0) jumpBuffer--;


 if(jumpBuffer > 0 && grounded){
  mario.vy = JUMP_VEL;
  jumpBuffer = 0;
 }

 // --- Gravity ---
 mario.vy += GRAVITY;
 if(mario.vy > MAX_FALL) mario.vy = MAX_FALL;

 // --- Apply movement ---
 mario.x += mario.vx;

 mario.y += mario.vy;

 // --- vertical collision ---
 I64 left   = WorldToTile(mario.x);
 I64 right  = WorldToTile(mario.x + 31);
 I64 top    = WorldToTile(mario.y);
 I64 bottom = WorldToTile(mario.y + 31);

 // falling
 if(mario.vy > 0){
  if(IsSolidTile(left, bottom) || IsSolidTile(right, bottom)){
   mario.y = bottom * TILE_SIZE - 32;
   mario.vy = 0;
  }
 }
 // jumping
 else if(mario.vy < 0){
  if(IsSolidTile(left, top) || IsSolidTile(right, top)){
   mario.y = (top + 1) * TILE_SIZE;
   mario.vy = 0;
  }
 }

 //recompute AFTER correction
 bottom = WorldToTile(mario.y + 31);
 grounded =
 IsSolidTile(left,  WorldToTile(mario.y + 32)) ||
 IsSolidTile(right, WorldToTile(mario.y + 32));
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
 I64 x, y;

 // --- Background ---
 GrBlot3(dc,0,64,0,SPRITEBG);

 // --- Draw level tiles ---
 for(y = 0; y < clvl->h; y++){
  for(x = 0; x < clvl->w; x++){

   if(clvl->tiles[y * clvl->w + x] == 1){
    GrBlot3(dc, x * 32, y * 32, 0, FLOOR1);
   }

  }
 }

 UpdateMario();

 CDC* spr = GetMarioSprite();
 GrBlot3(dc,mario.x,mario.y,0,spr);
}


U0 SongTask()
{
 Fs->task_end_cb=&SndTaskEndCB;
 MusicSettingsRst;
 while(TRUE){
  music.tempo = 3;
  music.stacatto_factor = .5;
  Play("5eEqEEeCEhG4hGq5C4GeEABttB#..");
  Play("AG5EGAFGECDq4hB5qC4GeErABttB#..AG");
  Play("e5EGAFGECD4Brr");
  Play("5ettGF#F..D#E4A#A5C4A5ttCD..rr");
  Play("5ttGF#F..D#EGrGG");
  Play("5ettGF#F..D#E4A#A5C4A5ttCD..rr");
  Play("5D#DC");
 }

}
U8 *WORLD_FILE = MStrPrint("%s%s",DirCur,"/Levels/World1-1.TXT");

U0 MarioMain()
{
 CDC *dc = DCAlias;
 I64 arg1, arg2;
 U8 input;

 SettingsPush; WinMax; WinBorder;
 DocCursor; DocClear;

 InitMario();
 clvl = LoadLevel(WORLD_FILE);
 Fs->draw_it = &DrawMarioGame;
 Fs->song_task=Spawn(&SongTask,Fs);

 while(TRUE)
 {
  input = GetMsg(&arg1,&arg2,
    1<<MSG_KEY_DOWN | 1<<MSG_KEY_UP);

  switch(input)
  {
   case MSG_KEY_DOWN:
    switch(arg1)
    {
     case 'a': case 'A': keyL = 1; break;
     case 'd': case 'D': keyR = 1; break;
     case 'w': case 'W': case ' ': keyJump = 1; break;
     case CH_ESC: goto fs_end;
    }

    if(arg1 == 0){
     switch(arg2.u8[0]){
      case SC_CURSOR_LEFT:  keyL = 1; break;
      case SC_CURSOR_RIGHT: keyR = 1; break;
      case SC_CURSOR_UP:    keyJump = 1; break;
     }
    }
   break;

   case MSG_KEY_UP:
    switch(arg1)
    {
     case 'a': case 'A': keyL = 0; break;
     case 'd': case 'D': keyR = 0; break;
     case 'w': case 'W': case ' ': keyJump = 0; break;
    }

    if(arg1 == 0){
     switch(arg2.u8[0]){
      case SC_CURSOR_LEFT:  keyL = 0; break;
      case SC_CURSOR_RIGHT: keyR = 0; break;
      case SC_CURSOR_UP:    keyJump = 0; break;
     }
    }
   break;
  }

  Refresh;
 }

fs_end:
 DCDel(dc);
 SettingsPop;
}

MarioMain;