#include "Wad.HC";
#include "Globals.HC";
#include "Level.HC";
#include "Game.HC";
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

   case TILE_BRICK: // brick
    GrBlot3(dc, x*32 - camX, y*32, 0, FLOOR2);
    break;
  
   case TILE_QUESTION: // ? block (coin)
   case TILE_Q_MUSHRM: // ? block (mushroom)
    I64 idx = y * clvl->w + x;
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
      GrBlot3(dc, x*32 - camX, y*32, 0, spr);
     }
     else{
      // used block
      GrBlot3(dc, x*32 - camX, y*32, 0, Q4);
     }
    }
    break;
   }
  }
 }

 UpdateMario();

 CDC* player = GetMarioSprite();
 GrBlot3(dc,mario.x -camX,mario.y,0,player);
}


U0 SongTask()
{
 Fs->task_end_cb=&SndTaskEndCB;
 MusicSettingsRst;
 while(TRUE){
  music.tempo = 2;
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
U0 AnimateTask()
{
 while(TRUE){
  if(jumpSoundActive){
   jumpSoundActive = 0;

   music.tempo=24;
   Play("e4DC#DD#EFF#GG#AA#B5CC#D"); //blocks here, which is fine in this thread
   music.tempo=2;
  }

  Yield;  // or Sleep(1) depending on your system
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
 Fs->animate_task=Spawn(&AnimateTask,Fs);

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